// On ne fait PAS d'import de Trix ici.
// On attend que le navigateur l'ait chargé via application.js

const setupTrix = () => {
    // On récupère Trix depuis l'objet global window
    const Trix = window.Trix

    if (!Trix) return

    // On ajoute le H2 dans la config
    Trix.config.blockAttributes.heading2 = {
        tagName: "h2",
        terminal: true,
        breakOnReturn: true,
        group: false
    }

    // On écoute l'initialisation pour le bouton
    document.addEventListener("trix-initialize", (event) => {
        const { toolbarElement } = event.target
        const blockTools = toolbarElement.querySelector(".trix-button-group--block-tools")

        if (blockTools && !blockTools.querySelector("[data-trix-attribute='heading2']")) {
            blockTools.insertAdjacentHTML("afterbegin", `
        <button type="button" class="trix-button" data-trix-attribute="heading2" title="Titre 2">H2</button>
      `)
        }
    })
}

// On lance la config
setupTrix()