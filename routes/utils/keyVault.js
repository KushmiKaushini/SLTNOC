const { DefaultAzureCredential } = require('@azure/identity');
const { SecretClient } = require('@azure/keyvault-secrets');

// Azure Key Vault configuration
const keyVaultName = process.env.KEY_VAULT_NAME || '';
const keyVaultUri = keyVaultName ? `https://${keyVaultName}.vault.azure.net/` : null;

let secretClientInstance = null;
let sqlCredentialsCache = null;
let credentialsFetchPromise = null;

/**
 * Returns an instance of SecretClient if KEY_VAULT_NAME is configured, or null.
 */
function getKeyVaultClient() {
  if (!keyVaultUri) return null;
  if (!secretClientInstance) {
    try {
      const credential = new DefaultAzureCredential();
      secretClientInstance = new SecretClient(keyVaultUri, credential);
    } catch (err) {
      console.warn(`[KeyVault] Failed to initialize SecretClient: ${err.message}`);
      return null;
    }
  }
  return secretClientInstance;
}

/**
 * Builds default DB credentials from environment variables.
 */
function getDefaultSqlCredentials() {
  return {
    user: process.env.DB_USER || 'sa',
    password: process.env.DB_PASSWORD || '',
    server: process.env.DB_SERVER || 'localhost\\SQLEXPRESS',
    database: process.env.DB_DATABASE || 'TMS',
    options: {
      trustedconnection: false,
      enableArithAbort: true,
      encrypt: true, // Always encrypt for Azure SQL
      trustServerCertificate: false,
      instancename: process.env.DB_INSTANCE || 'SQLEXPRESS',
      port: Number(process.env.DB_PORT || 1433),
    },
  };
}

/**
 * Retrieves a single secret value from Azure Key Vault or falls back to an environment variable/default.
 * @param {string} secretName - Name of the secret in Key Vault (e.g., 'DB-Password')
 * @param {string} [fallbackEnvVar] - Environment variable name to check if Key Vault is not configured or fails
 * @param {string} [defaultValue=''] - Default value if secret and env var are both undefined
 */
async function getSecret(secretName, fallbackEnvVar, defaultValue = '') {
  const envVal = fallbackEnvVar ? process.env[fallbackEnvVar] : undefined;
  const client = getKeyVaultClient();
  if (!client) {
    return envVal !== undefined ? envVal : defaultValue;
  }
  try {
    const secret = await client.getSecret(secretName);
    return secret?.value !== undefined ? secret.value : defaultValue;
  } catch (err) {
    console.warn(`[KeyVault] Failed to fetch secret '${secretName}': ${err.message}. Using fallback.`);
    return envVal !== undefined ? envVal : defaultValue;
  }
}

/**
 * Fetches SQL Server credentials with in-memory caching and request deduplication.
 * Pulls from Azure Key Vault if configured, otherwise falls back to environment variables.
 */
async function getSqlCredentials() {
  if (sqlCredentialsCache) {
    return sqlCredentialsCache;
  }

  if (credentialsFetchPromise) {
    return credentialsFetchPromise;
  }

  credentialsFetchPromise = (async () => {
    const client = getKeyVaultClient();
    if (!client) {
      sqlCredentialsCache = getDefaultSqlCredentials();
      return sqlCredentialsCache;
    }

    try {
      const [dbUserSecret, dbPasswordSecret, dbServerSecret, dbDatabaseSecret, dbInstanceSecret, dbPortSecret] = await Promise.all([
        client.getSecret('DB-User'),
        client.getSecret('DB-Password'),
        client.getSecret('DB-Server'),
        client.getSecret('DB-Database'),
        client.getSecret('DB-Instance'),
        client.getSecret('DB-Port'),
      ]);

      const credentials = {
        user: dbUserSecret.value,
        password: dbPasswordSecret.value,
        server: dbServerSecret.value,
        database: dbDatabaseSecret.value,
        options: {
          trustedconnection: false,
          enableArithAbort: true,
          encrypt: true,
          trustServerCertificate: false,
          instancename: dbInstanceSecret.value,
          port: Number(dbPortSecret.value),
        },
      };

      sqlCredentialsCache = credentials;
      return credentials;
    } catch (error) {
      console.warn('Failed to fetch SQL Server credentials from Azure Key Vault:', error.message);
      console.warn('Falling back to environment variables for SQL Server configuration');
      sqlCredentialsCache = getDefaultSqlCredentials();
      return sqlCredentialsCache;
    }
  })();

  return credentialsFetchPromise;
}

/**
 * Invalidate cached credentials (useful during testing or secret rotation)
 */
function clearCredentialsCache() {
  sqlCredentialsCache = null;
  credentialsFetchPromise = null;
}

module.exports = {
  getKeyVaultClient,
  getSecret,
  getSqlCredentials,
  getDefaultSqlCredentials,
  clearCredentialsCache,
};
