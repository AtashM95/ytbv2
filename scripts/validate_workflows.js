const fs = require('fs');
const path = require('path');

const workflowsDir = path.join(__dirname, '..', 'exports', 'n8n-workflows');
const requiredEnvVars = [
  'N8N_BASE_URL',
  'OPENAI_API_KEY',
  'ELEVENLABS_API_KEY',
  'YOUTUBE_API_KEY',
  'SHOTSTACK_API_KEY',
  'SHOTSTACK_SANDBOX_KEY',
  'PEXELS_API_KEY',
  'CLOUDINARY_CLOUD_NAME',
  'CLOUDINARY_API_KEY',
  'CLOUDINARY_API_SECRET',
];

const errors = [];
const envRefs = new Set();

const files = fs
  .readdirSync(workflowsDir)
  .filter((file) => file.endsWith('.json'))
  .map((file) => path.join(workflowsDir, file));

for (const file of files) {
  let data;
  try {
    const raw = fs.readFileSync(file, 'utf8');
    data = JSON.parse(raw);

    if (!Array.isArray(data.nodes) || data.nodes.length === 0) {
      errors.push(`${path.relative(process.cwd(), file)}: missing nodes array`);
    }

    if (!data.connections || typeof data.connections !== 'object') {
      errors.push(`${path.relative(process.cwd(), file)}: missing connections object`);
    }

    const envMatches = raw.matchAll(/\$env\.([A-Z0-9_]+)/g);
    for (const match of envMatches) {
      envRefs.add(match[1]);
    }
  } catch (err) {
    errors.push(`${path.relative(process.cwd(), file)}: ${err.message}`);
  }
}

for (const envVar of requiredEnvVars) {
  if (!envRefs.has(envVar)) {
    errors.push(`Missing env reference in workflows: ${envVar}`);
  }
}

if (errors.length > 0) {
  console.error('Workflow validation failed:');
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exit(1);
}

console.log(`Workflow validation OK (${files.length} workflows checked).`);
