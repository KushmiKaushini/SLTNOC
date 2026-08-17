// Main file to call APIs when needed

const express = require('express');
const cors = require('cors');
const alarmsRoutes1 = require('./routes/alarms1');
const alarmsRoutes2 = require('./routes/alarms2');
const regionsRoutes1 = require('./routes/provinces');
const alarmsDetails1 = require('./routes/alarmsDetails1');
const nodeDetails = require('./routes/nodeDetails');
const manualEscalations = require('./routes/manualEscalations');
const { Ollama } = require('ollama');
const aiTools = require('./routes/aiTools');

const app = express();

// In-memory cache for /api/critical-alerts (30-60 second TTL)
let criticalAlertsCache = {
  data: null,
  timestamp: 0,
  ttl: 45000 // 45 seconds
};

// CORS middleware
app.use(cors());
app.use(express.json());

// Initialize Ollama client
const ollama = new Ollama({ host: process.env.OLLAMA_HOST || 'http://localhost:11434' });

const NOC_SYSTEM_PROMPT = `You are an AI assistant for a Network Operations Center (NOC) monitoring system. 
You help users with:
- Alarm monitoring and troubleshooting
- Network element locations and status
- Service orders and work groups
- Escalations and planned outages
- Clarity system integration

Provide helpful, concise responses based on the context provided.
CRITICAL LANGUAGE RULES:
1. Detect the user's language automatically.
2. If the user asks in Sinhala (සිංහල) or Singlish (Sinhala using English letters), you MUST respond in clear, grammatically correct, natural Sinhala (සිංහල).
3. Keep technical codes, node names, and group identifiers (e.g., Colombo_MSAN_02, eNodeB, CEN-CSC-NW) intact in Latin letters for technical accuracy.`;

// Mapping for Sri Lankan provinces in English, Sinhala Script, and Singlish
const PROVINCE_MAP = [
  { key: 'Western', terms: ['western', 'බස්නාහිර', 'basnahira'] },
  { key: 'Southern', terms: ['southern', 'දකුණ', 'dakuna'] },
  { key: 'Central', terms: ['central', 'මධ්‍යම', 'madyama'] },
  { key: 'Sabaragamuwa', terms: ['sabaragamuwa', 'සබරගමුව'] },
  { key: 'Eastern', terms: ['eastern', 'නැගෙනහිර', 'nagenahira'] },
  { key: 'Uva', terms: ['uva', 'ඌව'] },
  { key: 'Northern', terms: ['northern', 'උතුර', 'uthura'] },
  { key: 'North Western', terms: ['north western', 'වයඹ', 'wayamba'] },
  { key: 'North Central', terms: ['north central', 'උතුරු මැද', 'uthuru mada'] }
];

const ESCALATION_TERMS = ['escalat', 'එස්කලේෂන්', 'එස්කලේශන්', 'එස්කලෙෂන්'];
const SUMMARY_TERMS = ['alarm', 'fault', 'status', 'summary', 'ඇලර්ම්', 'දෝෂ', 'තත්ත්වය', 'තත්වය', 'විස්තර', 'තොරතුරු'];
const RECURRING_TERMS = ['repeat', 'recur', 'frequent', 'predict', 'high risk', 'long duration', 'නැවත නැවත', 'නිතර'];

const MODEL = process.env.OLLAMA_MODEL || 'llama3';

// Helper function to detect intent and fetch database context concurrently
async function detectIntentAndFetchContext(userMessage) {
  const query = userMessage.toLowerCase();
  const tasks = [];

  // 1. Check for manual escalations (English & Sinhala/Singlish)
  if (ESCALATION_TERMS.some(term => query.includes(term))) {
    tasks.push(aiTools.getManualEscalations().then(escalations => {
      if (escalations && escalations.length > 0) {
        return `\n[SYSTEM CONTEXT - ACTIVE MANUAL ESCALATIONS]:\n${JSON.stringify(escalations, null, 2)}\n`;
      }
      return `\n[SYSTEM CONTEXT]: There are currently no active manual escalations.\n`;
    }));
  }

  // 2. Check for specific province queries (English, Sinhala Unicode, Singlish)
  let matchedProvince = null;
  for (const item of PROVINCE_MAP) {
    if (item.terms.some(t => query.includes(t))) {
      matchedProvince = item.key;
      break;
    }
  }

  if (matchedProvince) {
    tasks.push(aiTools.getAlarmsByProvince(matchedProvince).then(alarms => {
      if (alarms && alarms.length > 0) {
        return `\n[SYSTEM CONTEXT - OPEN ALARMS IN ${matchedProvince.toUpperCase()} PROVINCE]:\n${JSON.stringify(alarms.slice(0, 5), null, 2)}\n`;
      }
      return `\n[SYSTEM CONTEXT]: There are currently no open alarms/faults in the ${matchedProvince} province.\n`;
    }));
  }

  // 3. Check for specific group / NW_ENG names (e.g. CEN-CSC-NW, CEN-CSC-DATA, etc.)
  const groupMatch = userMessage.match(/[A-Z]{3}-[A-Z]{3}(-[A-Z]{2,4})?/);
  if (groupMatch) {
    const groupName = groupMatch[0];
    tasks.push(aiTools.getAlarmsByGroup(groupName).then(alarms => {
      if (alarms && alarms.length > 0) {
        return `\n[SYSTEM CONTEXT - OPEN ALARMS FOR ENGINEERING GROUP ${groupName}]:\n${JSON.stringify(alarms.slice(0, 5), null, 2)}\n`;
      }
      return `\n[SYSTEM CONTEXT]: There are currently no open alarms/faults for the engineering group ${groupName}.\n`;
    }));
  }

  // 4. Check for node details
  const nodeMatches = userMessage.match(/\b([A-Za-z0-9_-]*(MSAN|OLT|BTS|NODEB|ENODEB|CEA)[A-Za-z0-9_-]*)\b/i);
  if (nodeMatches) {
    const nodeName = nodeMatches[1];
    tasks.push(aiTools.getNodeDetails(nodeName).then(details => {
      if (details && details.length > 0) {
        return `\n[SYSTEM CONTEXT - RECENT/ACTIVE ALARMS FOR NODE ${nodeName}]:\n${JSON.stringify(details.slice(0, 5), null, 2)}\n`;
      }
      return `\n[SYSTEM CONTEXT]: No alarm records found for node ${nodeName}.\n`;
    }));
  }

  // 5. Check for recurring/predictive/high-risk fault analytics
  if (RECURRING_TERMS.some(term => query.includes(term))) {
    tasks.push(aiTools.getRecurringFaultNodes().then(recurring => {
      if (recurring && recurring.length > 0) {
        return `\n[SYSTEM CONTEXT - RECURRING & HIGH-RISK FAULT NODES]:\n${JSON.stringify(recurring, null, 2)}\n`;
      }
      return `\n[SYSTEM CONTEXT]: No recurring or high-risk fault patterns currently identified.\n`;
    }));
  }

  try {
    const results = await Promise.all(tasks);
    let context = results.join('');

    // 6. Fallback general summary if no specific context was matched
    if (context === '' && SUMMARY_TERMS.some(term => query.includes(term))) {
      const summary = await aiTools.getAlarmsSummary();
      if (summary) {
        context = `\n[SYSTEM CONTEXT - GENERAL ALARMS SUMMARY]:\n${JSON.stringify(summary, null, 2)}\n`;
      }
    }

    return context;
  } catch (err) {
    console.error('Error fetching context for AI:', err);
    return '';
  }
}

// Shared Ollama call options.
// think:false stops "thinking" models (e.g. qwen3.x) from spending the
// token budget on invisible reasoning and returning empty content.
// num_predict/num_ctx bumped up so answers aren't cut short mid-sentence.
const OLLAMA_OPTIONS = {
  num_ctx: 2048,
  num_predict: 500,
  temperature: 0.2,
  top_k: 20,
  top_p: 0.9,
};

// ── Non-streaming AI Chat endpoint (kept for fallback) ──────────────────────
app.post('/api/chat', async (req, res) => {
  try {
    const { message, conversationHistory } = req.body;

    const context = await detectIntentAndFetchContext(message);

    const messages = [
      { role: 'system', content: NOC_SYSTEM_PROMPT }
    ];

    if (context) {
      messages.push({ 
        role: 'system', 
        content: `Here is real-time system/database data relevant to the user request. Use this facts in your response: ${context}` 
      });
    }

    const recentHistory = (conversationHistory || []).slice(-8);
    messages.push(...recentHistory);
    messages.push({ role: 'user', content: message });

    const response = await ollama.chat({
      model: MODEL,
      messages: messages,
      stream: false,
      think: false,
      options: OLLAMA_OPTIONS,
      keep_alive: '24h'
    });

    const replyText = response.message?.content?.trim() || '';

    res.json({
      success: true,
      response: replyText || "Sorry, I couldn't generate a response for that. Could you try rephrasing?"
    });
  } catch (error) {
    console.error('AI Chat error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to process AI response'
    });
  }
});

// ── Streaming AI Chat endpoint (SSE) ────────────────────────────────────────
app.post('/api/chat-stream', async (req, res) => {
  try {
    const { message, conversationHistory } = req.body;

    const context = await detectIntentAndFetchContext(message);

    const messages = [
      { role: 'system', content: NOC_SYSTEM_PROMPT }
    ];

    if (context) {
      messages.push({ 
        role: 'system', 
        content: `Here is real-time system/database data relevant to the user request. Use this facts in your response: ${context}` 
      });
    }

    const recentHistory = (conversationHistory || []).slice(-8);
    messages.push(...recentHistory);
    messages.push({ role: 'user', content: message });

    // Set SSE headers
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('X-Accel-Buffering', 'no');
    res.flushHeaders();

    const stream = await ollama.chat({
      model: MODEL,
      messages: messages,
      stream: true,
      think: false,
      options: OLLAMA_OPTIONS,
      keep_alive: '24h'
    });

    let sentAnyToken = false;

    for await (const chunk of stream) {
      // Debug logging — enable via DEBUG_CHUNKS env var for troubleshooting
      if (process.env.DEBUG_CHUNKS === 'true') {
        console.log('CHUNK:', JSON.stringify(chunk.message));
      }

      const token = chunk.message?.content || '';
      if (token) {
        sentAnyToken = true;
        res.write(`data: ${JSON.stringify({ token })}\n\n`);
      }
    }

    // Safety net: if the model finished with zero visible content
    // (thinking-only output, empty generation, etc.), tell the client
    // instead of silently closing the stream with nothing sent.
    if (!sentAnyToken) {
      console.warn('Stream completed with no content tokens for message:', message);
      res.write(`data: ${JSON.stringify({ token: "Sorry, I couldn't generate a response for that. Could you try rephrasing or asking again?" })}\n\n`);
    }

    res.write('data: [DONE]\n\n');
    res.end();
  } catch (error) {
    console.error('AI Stream error:', error);
    try {
      res.write(`data: ${JSON.stringify({ error: 'Stream failed' })}\n\n`);
      res.end();
    } catch (_) {}
  }
});

// ── Critical Alerts check endpoint (for proactive banner in mobile app) ────
app.get('/api/critical-alerts', async (req, res) => {
  try {
    const now = Date.now();
    // Return cached data if still valid
    if (criticalAlertsCache.data && (now - criticalAlertsCache.timestamp) < criticalAlertsCache.ttl) {
      return res.json({ success: true, alert: criticalAlertsCache.data, cached: true });
    }
    
    // Fetch fresh data
    const alertData = await aiTools.getCriticalAlarmsAlert();
    criticalAlertsCache.data = alertData;
    criticalAlertsCache.timestamp = now;
    
    res.json({ success: true, alert: alertData });
  } catch (error) {
    // If we have cached data, return it even if stale on error
    if (criticalAlertsCache.data) {
      return res.json({ success: true, alert: criticalAlertsCache.data, cached: true, stale: true });
    }
    res.status(500).json({ success: false, error: 'Alert check failed' });
  }
});

// ── Health check for Ollama ──────────────────────────────────────────────────
app.get('/api/ai-health', async (req, res) => {
  try {
    const response = await ollama.list();
    res.json({ success: true, models: response.models, currentModel: MODEL });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Ollama service not available' });
  }
});

// Warmup Ollama model into memory on startup
async function warmupOllama() {
  try {
    console.log(`Warming up Ollama model (${MODEL})...`);
    await ollama.chat({
      model: MODEL,
      messages: [{ role: 'user', content: 'hi' }],
      think: false,
      options: { num_predict: 20 },
      keep_alive: '24h'
    });
    console.log(`Ollama model (${MODEL}) warmed up and retained in memory.`);
  } catch (err) {
    console.warn('Ollama warmup note:', err.message);
  }
}

// Use routes
app.use('/api/alarms1', alarmsRoutes1);
app.use('/api/alarms2', alarmsRoutes2);
app.use('/api/provinces', regionsRoutes1);
app.use('/api/alarm-details', alarmsDetails1);
app.use('/api/node-details', nodeDetails);
app.use('/api/manual-escalations', manualEscalations);

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  warmupOllama();
});