# Define the base directory
$baseDir = "element-copier"

# Define directories to create
$directories = @(
    "$baseDir/popup",
    "$baseDir/icons",
    "$baseDir/scripts",
    "$baseDir/styles"
)

# Define files to create with their initial content
$files = @{
    "$baseDir/manifest.json" = @'
{
  "manifest_version": 3,
  "name": "Element Copier",
  "version": "1.0",
  "description": "Copy DOM elements and their styles, convert to JSX and TailwindCSS.",
  "permissions": [
    "activeTab",
    "scripting",
    "clipboardWrite"
  ],
  "action": {
    "default_popup": "popup/popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  },
  "background": {
    "service_worker": "scripts/background.js"
  },
  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "js": ["scripts/content.js"]
    }
  ]
}
'@

    "$baseDir/tailwind.config.js" = @'
module.exports = {
  content: [
    "./popup/**/*.{html,js}",
    "./scripts/**/*.{js,jsx,ts,tsx}",
    "./index.html"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
'@

    "$baseDir/package.json" = @'
{
  "name": "element-copier",
  "version": "1.0.0",
  "description": "Copy DOM elements and their styles, convert to JSX and TailwindCSS.",
  "main": "background.js",
  "scripts": {
    "build:css": "tailwindcss -i ./styles/tailwind.css -o ./styles/output.css --watch"
  },
  "devDependencies": {
    "tailwindcss": "^3.0.0"
  }
}
'@

    "$baseDir/.gitignore" = @'
node_modules/
dist/
output.css
'@

    "$baseDir/README.md" = @''

    "$baseDir/popup/popup.html" = @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Element Copier</title>
  <link href="../styles/output.css" rel="stylesheet">
</head>
<body class="bg-gray-800 text-white p-4">
  <h1 class="text-xl font-bold mb-4">Element Copier</h1>
  <div id="element-info" class="mb-4">
    <!-- Element information will be displayed here -->
  </div>
  <button id="copy" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">Copy</button>
  <button id="preview" class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded ml-2">Preview</button>
  <script src="popup.js"></script>
</body>
</html>
'@

    "$baseDir/popup/popup.js" = @'
chrome.runtime.onMessage.addListener((message) => {
  if (message.elementData) {
    const elementInfoDiv = document.getElementById('element-info');
    elementInfoDiv.innerHTML = `
      <h2 class="text-lg font-semibold">Selected Element:</h2>
      <p><strong>Tag:</strong> ${message.elementData.tagName}</p>
      <p><strong>ID:</strong> ${message.elementData.id}</p>
      <p><strong>Class:</strong> ${message.elementData.className}</p>
      <pre><code>${JSON.stringify(message.elementData.styles, null, 2)}</code></pre>
    `;
  }
});

document.getElementById('copy').addEventListener('click', () => {
  const elementInfoDiv = document.getElementById('element-info');
  navigator.clipboard.writeText(elementInfoDiv.innerText);
});
'@

    "$baseDir/scripts/background.js" = @'
chrome.action.onClicked.addListener((tab) => {
  chrome.scripting.executeScript({
    target: {tabId: tab.id},
    files: ["scripts/content.js"]
  });
});
'@

    "$baseDir/scripts/content.js" = @'
document.addEventListener("mouseover", (event) => {
  const target = event.target;
  target.style.outline = "2px solid red";
  target.addEventListener("mouseout", () => {
    target.style.outline = "";
  }, { once: true });
});

document.addEventListener("click", (event) => {
  event.preventDefault();
  event.stopPropagation();
  
  const target = event.target;
  const computedStyle = getComputedStyle(target);
  const rect = target.getBoundingClientRect();

  const elementData = {
    tagName: target.tagName,
    className: target.className,
    id: target.id,
    rect: {
      width: rect.width,
      height: rect.height
    },
    styles: {}
  };

  for (let property of computedStyle) {
    elementData.styles[property] = computedStyle.getPropertyValue(property);
  }

  chrome.runtime.sendMessage({ elementData });
});
'@

    "$baseDir/styles/tailwind.css" = @'
@tailwind base;
@tailwind components;
@tailwind utilities;
'@

    "$baseDir/styles/output.css" = ""
}

# Create directories
foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir
}

# Create files with initial content
foreach ($file in $files.Keys) {
    $content = $files[$file]
    New-Item -ItemType File -Force -Path $file -Value $content
}

Write-Host "Project structure created successfully."
