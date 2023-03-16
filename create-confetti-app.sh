#!/bin/bash

# Create a new directory for the project
mkdir confetti-electron-app
cd confetti-electron-app

# Initialize npm
npm init -y

# Install necessary dependencies
npm install electron
npm install canvas-confetti

# Create the main.js file
cat > main.js << EOF
const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  });

  win.loadFile('index.html');
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
EOF

# Create the preload.js file
cat > preload.js << EOF
const { contextBridge } = require('electron');
const confetti = require('canvas-confetti');

contextBridge.exposeInMainWorld('confetti', confetti);
EOF

# Create the index.html file
cat > index.html << EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Confetti Electron App</title>
  </head>
  <body>
    <script>
      document.addEventListener('click', (event) => {
        window.confetti.create(event.target, {
          resize: true,
          useWorker: true
        })({ particleCount: 200, spread: 200, origin: { x: event.clientX / window.innerWidth, y: event.clientY / window.innerHeight } });
      });
    </script>
  </body>
</html>
EOF

# Create a package.json start script
jq '.scripts.start = "electron ."' package.json > tmp.json && mv tmp.json package.json

echo "Confetti Electron app created successfully! To run the app, use 'npm start'"
