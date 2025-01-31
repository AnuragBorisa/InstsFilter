//
//  ContentView.swift
//  InstsFilter
//
//  Created by Anurag on 29/01/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
struct ContentView: View {
    @State private var selectedItem : PhotosPickerItem?
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var currentFilter : CIFilter = CIFilter.sepiaTone()
    @State private var showingFilter = false;
    @State private var beginImage : CIImage?
   
    
    let context = CIContext()
    
    func changeFilter(){
        showingFilter = true
    }
    
    func setFilter(_ filter:CIFilter){
        currentFilter = filter
        loadImage()
    }
    
    func loadImage(){
        Task{
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else {return}
            guard let inputImage = UIImage(data:imageData) else {return}
            
             beginImage = CIImage(image:inputImage)
            
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            
            applyProcessing()
        }
    }
    
    func applyProcessing(){
        
        let inputKeys = currentFilter.inputKeys
       

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
      
        
        guard let outputImage = currentFilter.outputImage else {return}
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {return}
         
                let uiImage = UIImage(cgImage: cgImage)
                
                processedImage = Image(uiImage: uiImage)
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                Spacer()
                PhotosPicker(selection: $selectedItem){
                if let processedImage{
                    processedImage
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("No picture",systemImage: "photo.badge.plus",description: Text("Tap to import a photo"))
                }
            }
                .onChange(of: selectedItem,loadImage)
                Spacer()
                
                HStack{
                    Text("Intensity")
                    Slider(value:$filterIntensity)
                        .onChange(of: filterIntensity, applyProcessing)
                }
                .padding(.vertical)
                
                HStack{
                    Button("Change Filter",action: changeFilter)
//                        change the filter
                    
                    Spacer()
//                    share the picture
                }
            }
            .padding([.horizontal,.bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilter){
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) { }
            }
            
        }
    }
}

#Preview {
    ContentView()
}
