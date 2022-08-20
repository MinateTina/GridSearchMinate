//
//  ContentView.swift
//  GridSearchMinate
//
//  Created by Minate on 8/20/22.
//

//{
//"feed": {
//"results": [
//{
//"artistName": "WarnerMedia",
//"id": "971265422",
//"releaseDate": "2015-04-07",
//"name": "HBO Max: Stream TV & Movies",
//"kind": "iosSoftware",
//"copyright": "© 2020 WarnerMedia Direct, LLC. All Rights Reserved.",
//"artistId": "1514826633",
//"artistUrl": "https://apps.apple.com/us/developer/warnermedia/id1514826633",
//"artworkUrl100": "https://is5-ssl.mzstatic.com/image/thumb/Purple113/v4/59/74/be/5974be18-9df4-c74a-ef19-6d0434186211/AppIconHBOMAX-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/200x200bb.png",
//"genres": [
//{
//"genreId": "6016",
//"name": "Entertainment",
//"url": "https://itunes.apple.com/us/genre/id6016"
//},
//{
//"genreId": "6012",
//"name": "Lifestyle",
//"url": "https://itunes.apple.com/us/genre/id6012"
//}
//],
//"url": "https://apps.apple.com/us/app/hbo-max-stream-tv-movies/id971265422"
//},

import SwiftUI
import SDWebImageSwiftUI

struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results: [Result]
}

struct Result: Decodable, Hashable {
    let copyright, name, artworkUrl100, releaseDate: String
}

//MVVM between models and views
class GridViewModel: ObservableObject {
    
//    @Published var items = 0..<15
    
    @Published var results = [Result]()
    
    init() {
//        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
//            self.items = 0..<15
        
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/ios-apps/new-apps-we-love/all/100/explicit.json") else { return }
        
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            
            guard let data = data else { return }
            
            do {
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                print(rss)
                self.results = rss.feed.results
            } catch {
                print("Failed to decode: \(err)")
            }
            
        }.resume()
    }
        
}


struct GridSearchView: View {
    
    @ObservedObject var vm = GridViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    //GridItem(.fixed(50)), for fancy designs
                    GridItem(.flexible(minimum: 100, maximum: 200), spacing: 12, alignment: .top),
                    GridItem(.flexible(minimum: 100, maximum: 200), spacing: 12, alignment: .top),
                    GridItem(.flexible(minimum: 100, maximum: 200), alignment: .top)
                ], alignment: .leading, spacing: 16) {
                    ForEach(vm.results, id:\.self) { app in
                        
                        AppInfo(app: app)
                    }
                }.padding(.horizontal, 12)
                
            }.navigationTitle("Grid Search Minate")
        }
    }
}

struct AppInfo: View {
    
    let app: Result
    
    var body: some View {
        VStack(alignment: .leading) {
            
            WebImage(url: URL(string: app.artworkUrl100))
                .resizable()
                .scaledToFit()
                .cornerRadius(22)
                
            Text(app.name)
                .font(.system(size: 10, weight: .semibold))
                .padding(.top, 4)
            Text(app.releaseDate)
                .font(.system(size: 9, weight: .regular))
            Text(app.copyright)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(.horizontal)
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GridSearchView()
    }
}
