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
import StoreKit

struct ContentView: View {
    @AppStorage("filterCount") var filterCount = 0;
    @Environment(\.requestReview) var requestReview
    @State private var selectedItem : PhotosPickerItem?
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var radius = 0.5
    @State private var scale = 0.5
    @State private var currentFilter : CIFilter = CIFilter.sepiaTone()
    @State private var showingFilter = false;
    @State private var beginImage : CIImage?
   
    var disableSlider:Bool {
        if (processedImage != nil) {
            return false;
        }
        return true;
    }
    
    let context = CIContext()
    
    func changeFilter(){
        showingFilter = true
    }
    
    @MainActor
    func setFilter(_ filter:CIFilter){
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        
        if filterCount >= 20 {
            requestReview()
        }
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
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(radius * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(scale * 10, forKey: kCIInputScaleKey) }
        
      
        
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
                
                VStack{
                    HStack{
                        Text("Intensity")
                        Slider(value:$filterIntensity)
                            .onChange(of: filterIntensity, applyProcessing)
                    }
                    
                    HStack{
                        Text("Radius")
                        Slider(value:$radius)
                            .onChange(of: radius, applyProcessing)
                    }
                    
                    HStack{
                        Text("Scale")
                        Slider(value:$scale)
                            .onChange(of: scale, applyProcessing)
                    }
    
                }
                .padding(.vertical)
                .disabled(disableSlider)
                
                HStack{
                    Button("Change Filter",action: changeFilter)
                        .disabled(disableSlider)
//                        change the filter
                    
                    Spacer()
//                    share the picture
                    
                    if let processedImage {
                        ShareLink(item: processedImage,preview: SharePreview("Instafilter image",image: processedImage))
                    }
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
                Button("Box Blur"){setFilter(CIFilter.boxBlur())}
                Button("Cancel", role: .cancel) { }
                
            }
            
        }
    }
}

#Preview {
    ContentView()
}
