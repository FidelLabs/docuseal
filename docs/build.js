const fs = require('fs');
const path = require('path');
const marked = require('marked');
const hljs = require('highlight.js');

// Configure marked with syntax highlighting
marked.setOptions({
  highlight: function (code, lang) {
    if (lang && hljs.getLanguage(lang)) {
      return hljs.highlight(code, { language: lang }).value;
    }
    return code;
  },
  breaks: true,
  gfm: true
});

const docsDir = __dirname;
const publicDir = path.join(docsDir, 'public');

// Create public directory
if (!fs.existsSync(publicDir)) {
  fs.mkdirSync(publicDir, { recursive: true });
}

// Copy assets
const assetsDir = path.join(publicDir, 'assets');
if (!fs.existsSync(assetsDir)) {
  fs.mkdirSync(assetsDir, { recursive: true });
}

// HTML template
const template = (title, content, nav) => `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title} - SignPaw API Documentation</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-light.min.css">
  <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🐾</text></svg>">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      line-height: 1.6;
      color: #1a1a1a;
      background: #f8f9fa;
    }
    .container {
      display: flex;
      min-height: 100vh;
    }
    .sidebar {
      width: 280px;
      background: #6366f1;
      color: #fff;
      padding: 2rem 1.5rem;
      position: fixed;
      height: 100vh;
      overflow-y: auto;
    }
    .sidebar h1 {
      font-size: 1.5rem;
      margin-bottom: 0.5rem;
      color: #fff;
      font-weight: 700;
    }
    .sidebar .subtitle {
      font-size: 0.9rem;
      color: rgba(255,255,255,0.8);
      margin-bottom: 2rem;
    }
    .sidebar nav a {
      display: block;
      padding: 0.5rem 0.75rem;
      color: rgba(255,255,255,0.85);
      text-decoration: none;
      border-radius: 6px;
      margin-bottom: 0.25rem;
      transition: all 0.2s;
      font-size: 0.95rem;
    }
    .sidebar nav a:hover {
      background: rgba(255,255,255,0.15);
      color: #fff;
    }
    .sidebar nav a.active {
      background: rgba(255,255,255,0.25);
      color: #fff;
      font-weight: 600;
    }
    .sidebar .section-title {
      font-size: 0.7rem;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: rgba(255,255,255,0.6);
      margin-top: 1.5rem;
      margin-bottom: 0.5rem;
      font-weight: 700;
    }
    .main {
      margin-left: 280px;
      flex: 1;
      padding: 3rem;
      max-width: 1200px;
    }
    .content {
      background: white;
      padding: 3rem;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }
    h1, h2, h3, h4 { margin-top: 2rem; margin-bottom: 1rem; color: #1a1a1a; font-weight: 700; }
    h1 { font-size: 2.5rem; margin-top: 0; color: #6366f1; }
    h2 { font-size: 2rem; border-bottom: 3px solid #6366f1; padding-bottom: 0.5rem; margin-top: 3rem; }
    h3 { font-size: 1.5rem; color: #6366f1; margin-top: 2rem; }
    p { margin-bottom: 1rem; color: #374151; line-height: 1.7; }
    pre {
      background: #f8f9fa;
      border: 1px solid #e5e7eb;
      padding: 1.5rem;
      border-radius: 8px;
      overflow-x: auto;
      margin: 1.5rem 0;
    }
    code {
      font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Fira Code', 'Courier New', monospace;
      font-size: 0.9em;
    }
    :not(pre) > code {
      background: #f0f0f0;
      padding: 0.2em 0.4em;
      border-radius: 3px;
      color: #e83e8c;
    }
    a { color: #6366f1; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .badge {
      display: inline-block;
      padding: 0.25rem 0.5rem;
      font-size: 0.75rem;
      font-weight: 600;
      border-radius: 4px;
      margin-right: 0.5rem;
    }
    .badge-get { background: #10b981; color: white; }
    .badge-post { background: #f59e0b; color: white; }
    .badge-put { background: #3b82f6; color: white; }
    .badge-delete { background: #ef4444; color: white; }
    @media (max-width: 768px) {
      .sidebar { display: none; }
      .main { margin-left: 0; padding: 1.5rem; }
      .content { padding: 1.5rem; }
    }
  </style>
</head>
<body>
  <div class="container">
    <aside class="sidebar">
      <h1>🐾 SignPaw</h1>
      <div class="subtitle">API Documentation</div>
      <nav>
        ${nav}
      </nav>
    </aside>
    <main class="main">
      <div class="content">
        ${content}
      </div>
    </main>
  </div>
</body>
</html>
`;

// Build navigation
const buildNav = (currentFile) => {
  const sections = [
    {
      title: 'Getting Started',
      items: [
        { file: 'index', label: 'Introduction' }
      ]
    },
    {
      title: 'API Reference',
      items: [
        { file: 'api/shell', label: 'cURL' },
        { file: 'api/javascript', label: 'JavaScript' },
        { file: 'api/nodejs', label: 'Node.js' },
        { file: 'api/python', label: 'Python' },
        { file: 'api/ruby', label: 'Ruby' },
        { file: 'api/php', label: 'PHP' },
        { file: 'api/go', label: 'Go' },
        { file: 'api/java', label: 'Java' },
        { file: 'api/csharp', label: 'C#' },
        { file: 'api/typescript', label: 'TypeScript' }
      ]
    },
    {
      title: 'Webhooks',
      items: [
        { file: 'webhooks/submission-webhook', label: 'Submission Events' },
        { file: 'webhooks/form-webhook', label: 'Form Events' },
        { file: 'webhooks/template-webhook', label: 'Template Events' }
      ]
    },
    {
      title: 'Embedding',
      items: [
        { file: 'embedding/signing-form-javascript', label: 'Signing Form (JS)' },
        { file: 'embedding/signing-form-react', label: 'Signing Form (React)' },
        { file: 'embedding/signing-form-vue', label: 'Signing Form (Vue)' },
        { file: 'embedding/signing-form-angular', label: 'Signing Form (Angular)' },
        { file: 'embedding/form-builder-javascript', label: 'Form Builder (JS)' },
        { file: 'embedding/form-builder-react', label: 'Form Builder (React)' },
        { file: 'embedding/form-builder-vue', label: 'Form Builder (Vue)' },
        { file: 'embedding/form-builder-angular', label: 'Form Builder (Angular)' }
      ]
    }
  ];

  let nav = '';
  sections.forEach(section => {
    nav += `<div class="section-title">${section.title}</div>`;
    section.items.forEach(item => {
      const active = currentFile === item.file ? 'active' : '';
      nav += `<a href="/${item.file}.html" class="${active}">${item.label}</a>`;
    });
  });

  return nav;
};

// Create index page
const indexContent = `
# SignPaw API Documentation

Welcome to the SignPaw API documentation. This API allows you to programmatically create, manage, and send documents for electronic signature.

## API Base URL

All API requests should be made to:

\`\`\`
https://app.signpaw.com
\`\`\`

## Authentication

All API requests require authentication using an API token. Include your token in the \`X-Auth-Token\` header:

\`\`\`bash
curl https://app.signpaw.com/api/templates \\
  -H "X-Auth-Token: YOUR_API_TOKEN"
\`\`\`

## Getting Your API Token

1. Log in to your SignPaw account at https://app.signpaw.com
2. Navigate to Settings → API
3. Copy your API token

## Rate Limits

- **100 requests per minute** per API token
- **1000 requests per hour** per API token

## Quick Start

### 1. List Templates

\`\`\`bash
curl https://app.signpaw.com/api/templates \\
  -H "X-Auth-Token: YOUR_API_TOKEN"
\`\`\`

### 2. Create a Submission

\`\`\`bash
curl -X POST https://app.signpaw.com/api/submissions \\
  -H "X-Auth-Token: YOUR_API_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "template_id": 1000001,
    "send_email": true,
    "submitters": [{
      "role": "First Party",
      "email": "signer@example.com"
    }]
  }'
\`\`\`

## Support

- **Email**: support@signpaw.com
- **Documentation**: https://api.signpaw.com
- **Dashboard**: https://app.signpaw.com

## SDKs & Libraries

Choose your preferred programming language from the sidebar to see code examples.
`;

const indexHtml = template('API Documentation', marked.parse(indexContent), buildNav('index'));
fs.writeFileSync(path.join(publicDir, 'index.html'), indexHtml);

// Process all markdown files
const processDirectory = (dir, basePath = '') => {
  const items = fs.readdirSync(dir);

  items.forEach(item => {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      processDirectory(fullPath, path.join(basePath, item));
    } else if (item.endsWith('.md')) {
      const markdown = fs.readFileSync(fullPath, 'utf8');
      const html = marked.parse(markdown);
      const fileName = item.replace('.md', '');
      const fileKey = basePath ? `${basePath}/${fileName}` : fileName;
      const title = fileName.charAt(0).toUpperCase() + fileName.slice(1).replace(/-/g, ' ');

      const fullHtml = template(title, html, buildNav(fileKey));

      const outputDir = path.join(publicDir, basePath);
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
      }

      const outputFile = path.join(outputDir, fileName + '.html');
      fs.writeFileSync(outputFile, fullHtml);
      console.log(`✓ Built ${fileKey}.html`);
    }
  });
};

// Process all directories
['api', 'webhooks', 'embedding'].forEach(dir => {
  const dirPath = path.join(docsDir, dir);
  if (fs.existsSync(dirPath)) {
    processDirectory(dirPath, dir);
  }
});

// Create 404 page
const notFoundContent = `
# Page Not Found

The page you're looking for doesn't exist.

[← Back to Documentation](/)
`;

const notFoundHtml = template('404 - Not Found', marked.parse(notFoundContent), buildNav(''));
fs.writeFileSync(path.join(publicDir, '404.html'), notFoundHtml);

console.log('\n✅ Documentation built successfully!');
console.log(`📁 Output directory: ${publicDir}`);
console.log('\n🚀 To deploy: npm run deploy');
console.log('🔍 To preview: npm run dev');
