//
//  MeView.swift
//  HotProspects
//
//  Created by Amit Shrivastava on 22/01/22.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MeView: View {
    @State private var name = "Anonymous"
    @State private var emailAddress = "you@yoursite.com"
    @State private var qrCode = UIImage()

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var body: some View {
        Form {
            TextField("Name", text: $name)
                .textContentType(.name)
                .font(.title)
            TextField("Email", text: $emailAddress)
                .textContentType(.emailAddress)
                .font(.title)
            Image(uiImage: qrCode)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .contextMenu {
                    Button {
                     //   let image = generateQRCode(from: "\(name)\n\(emailAddress)")
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: qrCode)
                    } label: {
                        Label("Save to photos", systemImage: "square.and.arrow.down")
                    }
                }
                
        }
        .navigationTitle("Your Code")
        .onAppear(perform: updateCode)
        .onChange(of: name) { _ in
            updateCode()
        }
        .onChange(of: emailAddress) { _ in
            updateCode()
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
              //  qrCode = UIImage(cgImage: cgImage)
                return UIImage(cgImage: cgImage)
              //  return qrCode
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()

    }
    
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
