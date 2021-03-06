import AppKit
import FlameGraphCore
import Foundation
import Yaap

class FlameGraphCommand: Command {
    let name = "FlameGraph"
    let documentation = "Generates FlameGraphs from Xcode Instruments traces."

    let outputPath = Argument<String>(documentation: "The path where the svg should be saves")
    let filePath = Option<String>(shorthand: "f", defaultValue: "", documentation: "The path of a txt that contains the trace copy")
    let silent = Option<Bool>(shorthand: "s", defaultValue: false, documentation: "Don't open the file after generation")


    let help = Help()
    let version = Version("1.0.0")

    func run(outputStream: inout TextOutputStream, errorStream _: inout TextOutputStream) throws {
        let content: String
        let fromFile = !filePath.value.isEmpty
        if fromFile {
            do {
                outputStream.write("📂 Load trace copy\n")
                content = try String(contentsOfFile: filePath.value)
            } catch {
                throw LoadFileError(path: filePath.value)
            }
        } else if let pasteBoardString = NSPasteboard.general.string(forType: .string) {
            content = pasteBoardString
        } else {
            throw MissingInputError.missingInputOrPasteboard
        }

        outputStream.write("🔎 Parse trace copy\n")
        guard let callGraph = TraceParser.parse(content: content) else {
            if fromFile {
                throw ParsingFailedError(path: filePath.value)
            } else {
                throw MissingInputError.missingInputOrPasteboard
            }
        }

        outputStream.write("🔨 Generate Output\n")

        let output: RenderTarget

        output = SVGRender.render(graph: callGraph)

        outputStream.write("💾 Save Output\n")
        do {
            try output.write(to: URL(fileURLWithPath: outputPath.value))
        } catch {
            throw SaveFileError(path: outputPath.value)
        }

        outputStream.write("🔥 Successfully saved Output to \(String(describing: outputPath.value!))\n")
        if silent.value == false {
            NSWorkspace.shared.openFile(outputPath.value)
        }
    }
}

FlameGraphCommand().parseAndRun()
