//
//  ContentView.swift
//  ImageSlider
//
//  Created by Vladislav Cernega on 10/10/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var images: [Image] = [
        Image("slide1"),
        Image("slide2"),
        Image("slide3"),
    ]
    @State private var currentIndex: Int = 0
    @State private var autoSlide: Bool = false
    @State private var timeInterval: Double = 1.0
    @State private var showPrompt: Bool = false
    @State private var timer: Timer? = nil
    @State private var showSlideList: Bool = false
    
    var body: some View {
        ZStack {
            // Main Image Slider
            images[currentIndex]
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
                .highPriorityGesture(
                    TapGesture(count: 2)
                        .onEnded {
                            if autoSlide {
                                autoSlide.toggle()
                            } else {
                                showPrompt.toggle()
                            }
                        }
                )
                .gesture(
                    DragGesture(minimumDistance: 150)
                        .onEnded { value in
                            let horizontalGesture = abs(value.translation.width)
                            let verticalGesture = abs(value.translation.height)
                            
                            if horizontalGesture > verticalGesture {
                                // Horizontal Swipe
                                if value.translation.width < 0 {
                                    // Swipe Left
                                    withAnimation {
                                        currentIndex = (currentIndex + 1) % images.count
                                    }
                                } else {
                                    // Swipe Right
                                    withAnimation {
                                        currentIndex = (currentIndex - 1 + images.count) % images.count
                                    }
                                }
                            } else {
                                // Vertical Swipe
                                if value.translation.height < 0 {
                                    // Swipe Up
                                    withAnimation {
                                        showSlideList = true
                                    }
                                } else {
                                    // Swipe Down
                                    withAnimation {
                                        showSlideList = false
                                    }
                                }
                            }
                        }
                )
            
            // Slide List at the bottom
            if showSlideList {
                VStack {
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<images.count, id: \.self) { index in
                                images[index]
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width / 6 - 10, height: 100)
                                    .clipped()
                                    .onTapGesture {
                                        withAnimation {
                                            currentIndex = index
                                            showSlideList = false
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    .background(Color.black.opacity(0.7))
                }
            }
            
            // TimerView
            if autoSlide {
                TimerView(timeInterval: $timeInterval, currentIndex: $currentIndex, imagesCount: images.count)
            }
        }
        .onChange(of: autoSlide) { newValue in
            if newValue {
                timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % images.count
                    }
                }
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
}

struct TimerView: View {
    @Binding var timeInterval: Double
    @Binding var currentIndex: Int
    let imagesCount: Int
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Auto-Sliding every \(timeInterval, specifier: "%.1f") seconds")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
