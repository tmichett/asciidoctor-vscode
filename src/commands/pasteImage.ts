import vscode from 'vscode'
import { Command } from '../commandManager'
import { Import } from '../image-paste'

import Configuration = Import.Configuration

import { AsciidocLoader } from '../asciidocLoader'

export class PasteImage implements Command {
  public readonly id = 'asciidoc.pasteImage'

  constructor(private readonly asciidocLoader: AsciidocLoader) {}

  public async execute() {
    try {
      const activeTextEditor = vscode.window.activeTextEditor
      if (activeTextEditor === undefined) {
        return
      }
      const configuration = new Configuration()

      // Read extension settings
      const editorConfig = vscode.workspace.getConfiguration(
        'asciidoc.editor',
        activeTextEditor.document.uri,
      )
      const settingsImageDir = editorConfig.get<string>(
        'pasteImage.directory',
        '',
      )
      const settingsFilenamePrefix = editorConfig.get<string>(
        'pasteImage.filenamePrefix',
        '',
      )

      // Use settings directory if provided, otherwise use document's imagesdir
      if (settingsImageDir) {
        configuration.ImagesDirectory = settingsImageDir
      } else {
        configuration.ImagesDirectory = await getCurrentImagesDir(
          this.asciidocLoader,
          activeTextEditor.document,
          activeTextEditor.selection,
        )
      }

      // Set filename prefix from settings
      configuration.FilenamePrefix = settingsFilenamePrefix

      await Import.Image.importFromClipboard(configuration)
    } catch (e) {
      vscode.window.showErrorMessage(e)
    }
  }
}

/**
 * Reads the current `:imagesdir:` [attribute](https://asciidoctor.org/docs/user-manual/#setting-the-location-of-images) from the document.
 *
 * Reads the _nearest_ `:imagesdir:` attribute that appears _before_ the current selection
 * or cursor location, failing that figures it out from the API by converting the document and reading the attribute
 */
export async function getCurrentImagesDir(
  asciidocLoader: AsciidocLoader,
  textDocument: vscode.TextDocument,
  selection: vscode.Selection,
) {
  const text = textDocument.getText()

  const imagesDir = /^[\t\f]*?:imagesdir:\s+(.+?)\s+$/gim
  let matches = imagesDir.exec(text)

  const index = selection.start
  const cursorIndex = textDocument.offsetAt(index)

  let dir = ''
  while (matches && matches.index < cursorIndex) {
    dir = matches[1] || ''
    matches = imagesDir.exec(text)
  }

  if (dir !== '') {
    return dir
  }

  const document = await asciidocLoader.load(textDocument)
  return document.getAttribute('imagesdir', '')
}
