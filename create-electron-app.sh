#!/bin/bash

# Prompt:
#   As a single code block, write a shell script that creates basic Electron app that can run on Linux, macOS, and Windows. It should contain a single screen, that when clicked, shows confetti.
#   Include all written instructions as code comments.
#   You can assume a node toolchain on macOS.

# 1. Check if Node.js and npm are installed
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "Node.js and npm are required to run this script. Please install them before running this script."
  exit 1
fi

# 2. Install Electron globally if not already installed
if ! command -v electron >/dev/null 2>&1; then
  echo "Installing Electron globally..."
  npm install -g electron
fi

# 3. Create a new directory for the Electron app and navigate to it
mkdir basic-electron-app
cd basic-electron-app

# 4. Initialize a new Node.js project
npm init -y

# 5. Install Electron and other dependencies
npm install electron canvas-confetti

# 6. Create the main.js file
cat > main.js << EOL
const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
    },
  });

  win.loadFile('index.html');
  win.webContents.openDevTools();
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
EOL

# 7. Create the index.html file
cat > index.html << EOL
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Basic Electron App with Confetti</title>
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      user-select: none;
    }
    canvas {
      display: block;
    }
  </style>
</head>
<body>
  <canvas id="confetti-canvas"></canvas>
  <script>
    const canvas = document.getElementById('confetti-canvas');
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    const confetti = require('canvas-confetti').create(canvas, {
      resize: true,
      useWorker: true,
    });

    document.body.addEventListener('click', () => {
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 },
      });
    });
  </script>
</body>
</html>
EOL

# 8. Update the package.json to set the entry point to main.js
sed -i.bak 's/"main": "index.js"/"main": "main.js"/' package.json && rm package.json.bak

# 9. Add a start script to package.json
sed -i.bak 's/"test": "echo \\"Error: no test specified\\" && exit 1"/"start": "electron ."/' package.json && rm package.json.bak

# 10. Run the Electron app
npm start
