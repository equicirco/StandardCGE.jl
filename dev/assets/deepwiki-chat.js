(() => {
  const baseUrl = "https://mcp.deepwiki.com";
  const protocolVersion = "2024-11-05";
  const defaultRepoName = null;

  if (document.getElementById("dw-chat-root")) {
    return;
  }

  const root = document.createElement("div");
  root.id = "dw-chat-root";
  root.className = "dw-chat";
  root.innerHTML = `
    <button class="dw-toggle" type="button" aria-label="Open Ask Devin chat">Ask Devin</button>
    <div class="dw-panel" role="dialog" aria-label="Ask Devin">
      <div class="dw-header">
        <div class="dw-title">
          <span>Ask Devin</span>
          <span class="dw-subtitle" data-dw-subtitle>Detecting repo...</span>
        </div>
        <button class="dw-close" type="button" aria-label="Close">✕</button>
      </div>
      <div class="dw-messages" role="log" aria-live="polite"></div>
      <div class="dw-input">
        <textarea rows="3" placeholder="Ask about this repo..."></textarea>
        <div class="dw-actions">
          <span class="dw-status">Idle</span>
          <button class="dw-send" type="button">Send</button>
        </div>
      </div>
    </div>
  `;

  const mountChat = () => {
    const insertAfter = (target, node) => {
      if (!target || !target.parentNode) {
        return false;
      }
      target.parentNode.insertBefore(node, target.nextSibling);
      return true;
    };

    const docsMenu = document.querySelector(".docs-sidebar .docs-menu");
    if (docsMenu && insertAfter(docsMenu, root)) {
      root.classList.add("dw-embedded");
      return;
    }

    const searchInput =
      document.querySelector("#documenter-search-query") ||
      document.querySelector(".docs-search-query") ||
      document.querySelector(".documenter-search input") ||
      document.querySelector("#documenter-search input") ||
      document.querySelector("input[type=\"search\"]") ||
      document.querySelector("input[placeholder*=\"Search\"]");

    if (searchInput) {
      const searchContainer =
        searchInput.closest(".documenter-search") ||
        searchInput.closest("form") ||
        searchInput;

      if (insertAfter(searchContainer, root)) {
        root.classList.add("dw-embedded");
        return;
      }
    }

    const wideScreen = window.matchMedia("(min-width: 1100px)").matches;
    const toc =
      document.querySelector(".documenter-toc") ||
      document.querySelector("nav.toc") ||
      document.getElementById("toc") ||
      document.querySelector(".toc");

    if (wideScreen && toc && toc.parentNode) {
      root.classList.add("dw-embedded");
      toc.parentNode.insertBefore(root, toc);
      return;
    }

    const content =
      document.querySelector(".documenter-content") ||
      document.querySelector("main") ||
      document.querySelector("article");

    if (content) {
      root.classList.add("dw-inline");
      content.prepend(root);
      return;
    }

    root.classList.add("dw-floating");
    document.body.appendChild(root);
  };

  const mountWhenReady = () => {
    mountChat();
    if (root.classList.contains("dw-embedded") || root.classList.contains("dw-inline")) {
      root.classList.add("dw-open");
    }
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", mountWhenReady);
  } else {
    mountWhenReady();
  }

  const toggleBtn = root.querySelector(".dw-toggle");
  const closeBtn = root.querySelector(".dw-close");
  const panel = root.querySelector(".dw-panel");
  const messagesEl = root.querySelector(".dw-messages");
  const textarea = root.querySelector("textarea");
  const sendBtn = root.querySelector(".dw-send");
  const statusEl = root.querySelector(".dw-status");
  const subtitleEl = root.querySelector("[data-dw-subtitle]");

  const resolveRepoName = () => {
    const githubLink = Array.from(document.querySelectorAll("a[href]")).find((link) => {
      return /https?:\/\/github\.com\/[^/]+\/[^/]+/.test(link.href);
    });

    if (githubLink) {
      const match = githubLink.href.match(/github\.com\/([^/]+)\/([^/#?]+)(?:\.git)?/);
      if (match) {
        return `${match[1]}/${match[2]}`;
      }
    }

    const hostMatch = window.location.hostname.match(/^([^.]+)\.github\.io$/);
    if (hostMatch) {
      const parts = window.location.pathname.split("/").filter(Boolean);
      if (parts.length > 0) {
        return `${hostMatch[1]}/${parts[0]}`;
      }
    }

    return defaultRepoName;
  };

  const repoName = resolveRepoName();
  const deepwikiUrl = repoName ? `https://deepwiki.com/${repoName}` : null;
  subtitleEl.textContent = repoName ? `DeepWiki for ${repoName}` : "DeepWiki repo not detected";
  subtitleEl.title = deepwikiUrl || "";

  const setStatus = (text) => {
    statusEl.textContent = text;
  };

  const addMessage = (role, text) => {
    const msg = document.createElement("div");
    msg.className = `dw-msg dw-${role}`;
    msg.textContent = text;
    messagesEl.appendChild(msg);
    messagesEl.scrollTop = messagesEl.scrollHeight;
    return msg;
  };

  const openPanel = () => {
    root.classList.add("dw-open");
    textarea.focus();
  };

  const closePanel = () => {
    root.classList.remove("dw-open");
  };

  toggleBtn.addEventListener("click", openPanel);
  closeBtn.addEventListener("click", closePanel);


  class DeepWikiMcpClient {
    constructor(onStatus) {
      this.eventSource = null;
      this.endpoint = null;
      this.sessionId = null;
      this.nextId = 1;
      this.pending = new Map();
      this.initPromise = null;
      this.readyPromise = null;
      this.readyResolve = null;
      this.connected = false;
      this.connectError = null;
      this.onStatus = onStatus;
    }

    connect() {
      if (this.readyPromise) {
        return this.readyPromise;
      }
      this.readyPromise = new Promise((resolve) => {
        this.readyResolve = resolve;
      });

      this.eventSource = new EventSource(`${baseUrl}/sse`);

      this.eventSource.addEventListener("endpoint", (event) => {
        this.endpoint = event.data.startsWith("http") ? event.data : `${baseUrl}${event.data}`;
        const match = event.data.match(/sessionId=([a-f0-9]+)/);
        if (match) {
          this.sessionId = match[1];
        }
        this.connected = true;
        this.readyResolve();
      });

      this.eventSource.addEventListener("message", (event) => {
        let payload;
        try {
          payload = JSON.parse(event.data);
        } catch (err) {
          return;
        }

        if (payload.method === "notifications/progress") {
          const token = payload.params && payload.params.progressToken;
          const pending = this.pending.get(token);
          if (pending && pending.onProgress) {
            pending.onProgress(payload.params.message || "");
          }
          return;
        }

        if (payload.id === undefined || payload.id === null) {
          return;
        }

        const pending = this.pending.get(payload.id);
        if (!pending) {
          return;
        }

        if (payload.error) {
          pending.reject(payload.error);
        } else {
          pending.resolve(payload.result);
        }
        this.pending.delete(payload.id);
      });

      this.eventSource.addEventListener("error", () => {
        this.connectError = "Connection lost. Please retry.";
        if (this.onStatus) {
          this.onStatus(this.connectError);
        }
      });

      return this.readyPromise;
    }

    async ensureInitialized() {
      if (this.initPromise) {
        return this.initPromise;
      }

      this.initPromise = (async () => {
        await this.connect();
        await this.send("initialize", {
          protocolVersion,
          clientInfo: {
            name: "DualSignalsDocs",
            version: "1.0.0",
          },
          capabilities: {},
        });
      })();

      return this.initPromise;
    }

    send(method, params) {
      if (!this.endpoint || !this.sessionId) {
        return Promise.reject(new Error("MCP endpoint not ready."));
      }

      const id = this.nextId++;
      const body = {
        jsonrpc: "2.0",
        id,
        method,
        params,
      };

      const request = new Promise((resolve, reject) => {
        this.pending.set(id, { resolve, reject });
      });

      fetch(this.endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json, text/event-stream",
          "mcp-protocol-version": protocolVersion,
          "mcp-session-id": this.sessionId,
        },
        body: JSON.stringify(body),
      }).catch((err) => {
        const pending = this.pending.get(id);
        if (pending) {
          pending.reject(err);
          this.pending.delete(id);
        }
      });

      return request;
    }

    askQuestion(question, onProgress) {
      const id = this.nextId++;
      const body = {
        jsonrpc: "2.0",
        id,
        method: "tools/call",
        params: {
          name: "ask_question",
          arguments: {
            repoName,
            question,
          },
        },
      };

      const request = new Promise((resolve, reject) => {
        this.pending.set(id, { resolve, reject, onProgress });
      });

      fetch(this.endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json, text/event-stream",
          "mcp-protocol-version": protocolVersion,
          "mcp-session-id": this.sessionId,
        },
        body: JSON.stringify(body),
      }).catch((err) => {
        const pending = this.pending.get(id);
        if (pending) {
          pending.reject(err);
          this.pending.delete(id);
        }
      });

      return request;
    }
  }

  if (!window.EventSource) {
    setStatus("EventSource not supported in this browser.");
    sendBtn.disabled = true;
  }

  const client = new DeepWikiMcpClient(setStatus);

  const sendQuestion = async () => {
    const question = textarea.value.trim();
    if (!question) {
      return;
    }
    if (!repoName) {
      addMessage("assistant", "Repo not detected. Add a GitHub link on the page or set defaultRepoName.");
      return;
    }

    textarea.value = "";
    addMessage("user", question);
    const assistantMsg = addMessage("assistant", "Thinking...");
    sendBtn.disabled = true;
    setStatus("Connecting...");

    try {
      await client.ensureInitialized();
      setStatus("Asking DeepWiki...");
      let buffer = "";

      const result = await client.askQuestion(question, (chunk) => {
        if (!chunk) {
          return;
        }
        buffer += chunk;
        assistantMsg.textContent = buffer;
        messagesEl.scrollTop = messagesEl.scrollHeight;
      });

      if (result && result.content) {
        if (Array.isArray(result.content)) {
          const text = result.content.map((item) => item.text || "").join("").trim();
          if (text) {
            assistantMsg.textContent = text;
          }
        } else if (typeof result.content === "string") {
          assistantMsg.textContent = result.content;
        }
      } else if (!buffer.trim()) {
        assistantMsg.textContent = "No response received yet. Please try again.";
      }

      setStatus("Ready");
    } catch (err) {
      assistantMsg.textContent = "Failed to reach DeepWiki MCP server.";
      setStatus("Error");
    } finally {
      sendBtn.disabled = false;
      messagesEl.scrollTop = messagesEl.scrollHeight;
    }
  };

  sendBtn.addEventListener("click", sendQuestion);
  textarea.addEventListener("keydown", (event) => {
    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
      sendQuestion();
    }
  });

  setStatus("Idle");
})();
