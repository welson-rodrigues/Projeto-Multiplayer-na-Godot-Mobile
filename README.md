# Servidor Multiplayer WebSocket para Godot Mobile

Este projeto foi **criado originalmente em 2022** por [ignurof](https://github.com/ignurof), utilizando a **Godot Engine 3.5** para jogos multiplayer no PC com WebSocket + Node.js.

---

## 🎮 Adaptação (2025)

Em **2025**, o projeto foi **adaptado por mim (Welson Rodrigues)** para funcionar com a **Godot 4.5 beta 1**, focando no uso **em dispositivos móveis (Android)** com a **Godot Mobile**.

As principais mudanças e avanços incluem:

* ✅ Atualização de toda a lógica para Godot 4.5 (nova API de sinais, nodes 2D)
* 📱 Suporte completo para **APK Android**, com exportação funcional
* 🧪 Testes locais utilizando o **Termux** como servidor Node.js
* ☁️ Implantação do servidor no [Render.com](https://render.com) com WebSocket seguro (`wss://`)
* 🔁 Sincronização em tempo real de múltiplos jogadores
* 💬 Sistema de chat multiplayer funcional
* 🔌 Detecção de desconexão de jogadores com remoção automática

---

## 📂 Estrutura

```
.
├── server.js         # Servidor WebSocket (Node.js + ws)
├── playerlist.js     # Gerenciamento de jogadores conectados
├── package.json      # Dependências do projeto (express, ws, uuid)
├── client.gd         # Cliente Godot (WebSocketPeer)
└── demo_map.gd       # Lógica de spawn e atualização de jogadores
```

---

## 🚀 Como executar

### Localmente com Termux:

```bash
pkg install nodejs
npm install
node server.js
```

### Online com Render:

* Crie um repositório no GitHub com os arquivos do servidor
* Vá até [https://render.com](https://render.com)
* Crie um novo serviço “Web Service” → conecte ao seu repositório
* Configure para rodar `node server.js`
* Pronto! Você terá uma URL como `wss://seuservidor.onrender.com`

---

## 📆 Exportando para APK

Na exportação para Android:

* Marque a permissão `INTERNET` em **Project > Export > Android > Permissions**
* Use `Client.connect_to_server()` com a URL do Render (ex: `wss://seuservidor.onrender.com`)
* Verifique que todos os scripts/autoloads estão sendo exportados corretamente

---

## 📝 Créditos

* Projeto original: [ignurof](https://github.com/ignurof)
* Adaptação para Godot 4.5 Mobile: **Welson Rodrigues (Zee GameDev)**

---

## 🎩 Vídeo/tutorial

🎮 Em breve: vídeo completo no meu canal mostrando como adaptar e implantar seu próprio multiplayer mobile com WebSocket!
