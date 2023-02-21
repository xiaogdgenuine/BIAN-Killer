import SwiftUI

struct AboutView: View {

    let onClose: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button("OK") {
                    onClose()
                }
            }

            VStack(spacing: 32) {
                Text("About BIAN Killer")
                        .font(.title)
                Text("Icon from [Freepik - Flaticon](https://www.flaticon.com/free-icons/target)")

                HStack {
                    Text("How it works?")
                    Text("https://github.com/xiaogdgenuine/BIAN-Killer")
                }

                HStack {
                    Image(systemName: "cup.and.saucer")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                    Text("Buy me a coffee")
                        .foregroundColor(.black)
                }
                .contentShape(Rectangle())
                .padding()
                .padding(.horizontal, 24)
                .background(Color.yellow)
                .cornerRadius(12)
                .onTapGesture {
                    NSWorkspace.shared.open(URL(string: "https://www.buymeacoffee.com/xiaogd")!)
                }


                Text("My other apps")
                Image("Doll")
                    .resizable()
                    .frame(width: 32, height: 32).onTapGesture {
                        NSWorkspace.shared.open(URL(string: "https://github.com/xiaogdgenuine/doll")!)
                    }
                .cursor(.pointingHand)

            }.padding()

            Spacer()
        }.frame(maxHeight: .infinity)
    }
}
