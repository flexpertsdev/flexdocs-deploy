// Netlify Function to handle all API endpoints
const API_KEYS = {
  'demo-key-123': 'demo-project',
  // Add more API keys as needed
};

// In-memory storage (use Netlify Blobs or external DB in production)
const storage = new Map();

exports.handler = async (event, context) => {
  const path = event.path.replace('/.netlify/functions/api', '');
  const method = event.httpMethod;
  
  // Handle CORS
  if (method === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type, x-api-key',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
      }
    };
  }

  // Check API key
  const apiKey = event.headers['x-api-key'];
  if (!apiKey || !API_KEYS[apiKey]) {
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Invalid API key' })
    };
  }

  const projectId = API_KEYS[apiKey];

  try {
    // Route handlers
    if (path === '/files' && method === 'GET') {
      // Get all files for project
      const files = [];
      for (const [key, value] of storage.entries()) {
        if (key.startsWith(`${projectId}:`)) {
          const filePath = key.substring(projectId.length + 1);
          files.push({
            path: filePath,
            content: value.content,
            lastModified: value.lastModified
          });
        }
      }
      
      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ files })
      };
    }

    if (path === '/files' && method === 'POST') {
      // Upload files
      const { files } = JSON.parse(event.body);
      const results = [];
      
      for (const file of files) {
        const key = `${projectId}:${file.path}`;
        storage.set(key, {
          content: file.content,
          lastModified: new Date().toISOString()
        });
        results.push({ path: file.path, uploaded: true });
      }
      
      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ results })
      };
    }

    if (path === '/project' && method === 'GET') {
      // Get project info
      const fileCount = Array.from(storage.keys())
        .filter(key => key.startsWith(`${projectId}:`)).length;
      
      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          projectId, 
          fileCount,
          lastSync: new Date().toISOString()
        })
      };
    }

    return {
      statusCode: 404,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Not found' })
    };

  } catch (error) {
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: error.message })
    };
  }
};