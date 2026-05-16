(() => {
    let staticTitle = null;

    const deriveStaticTitle = () => {
        if (staticTitle) {
            return staticTitle;
        }

        const logo = document.querySelector('[data-md-component="logo"]');
        const fromLogo = logo?.getAttribute("title") ?? logo?.getAttribute("aria-label") ?? "";

        const headerEllipsis = document.querySelector(".md-header__topic .md-ellipsis");
        const fromHeader = headerEllipsis?.textContent ?? "";

        const titleParts = document.title?.split(" - ") ?? [];
        const fromTitle = titleParts.at(-1)?.trim() ?? "";

        staticTitle = (fromLogo || fromHeader || fromTitle || "Autoboat Documentation").trim();
        return staticTitle;
    };

    const setTitle = () => {
        document.title = deriveStaticTitle();
    };

    // Keep the tab title fixed across instant navigation and page loads.
    if (typeof document$ !== "undefined" && document$.subscribe) {
        document$.subscribe(setTitle);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", setTitle, { once: true });
    } else {
        setTitle();
    }
})();
