(() => {
  const base = window.documenterBaseURL || ".";
  const lightSrc = `${base}/assets/logo-light.png`;
  const darkSrc = `${base}/assets/logo-dark.png`;

  const isDarkTheme = () => {
    const cls = document.documentElement.className || "";
    if (
      cls.includes("theme--documenter-dark") ||
      cls.includes("theme--catppuccin-mocha") ||
      cls.includes("theme--catppuccin-macchiato") ||
      cls.includes("theme--catppuccin-frappe")
    ) {
      return true;
    }
    return window.matchMedia("(prefers-color-scheme: dark)").matches;
  };

  const applyLogo = () => {
    const sidebar = document.querySelector(".docs-sidebar");
    if (!sidebar) {
      return false;
    }

    let logoLink = sidebar.querySelector(".docs-logo");
    let logoImg = logoLink ? logoLink.querySelector("img") : null;

    if (!logoImg) {
      logoLink = document.createElement("a");
      logoLink.className = "docs-logo";
      logoLink.href = base;
      logoImg = document.createElement("img");
      logoImg.alt = "StandardCGE logo";
      logoLink.appendChild(logoImg);
      const packageName = sidebar.querySelector(".docs-package-name");
      if (packageName) {
        sidebar.insertBefore(logoLink, packageName);
      } else {
        sidebar.prepend(logoLink);
      }
    }

    logoImg.src = isDarkTheme() ? darkSrc : lightSrc;
    return true;
  };

  const updateLogo = () => {
    applyLogo();
  };

  const init = () => {
    if (!applyLogo()) {
      const retry = setInterval(() => {
        if (applyLogo()) {
          clearInterval(retry);
        }
      }, 50);
      setTimeout(() => clearInterval(retry), 2000);
    }

    const observer = new MutationObserver(updateLogo);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
