// app/javascript/controllers/trix_variables_controller.js
import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["editor"]

    insert(event) {
        const variable = event.currentTarget.dataset.variable
        const trixEditor = this.editorTarget.editor

        // Insère la variable à la position du curseur
        trixEditor.insertString(`{{${variable}}}`)

        // Redonne le focus à l'éditeur pour continuer la frappe
        this.editorTarget.focus()
    }
}