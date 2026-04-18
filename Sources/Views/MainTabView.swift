import SwiftUI

struct MainTabView: View {
  @State private var selectedTab = 0

  var body: some View {
    TabView(selection: $selectedTab) {
      HomeView()
        .tabItem {
          Image(systemName: "camera.fill")
          Text("분석")
        }
        .tag(0)

      SavedListView()
        .tabItem {
          Image(systemName: "bookmark.fill")
          Text("저장됨")
        }
        .tag(1)
    }
  }
}

#Preview {
  MainTabView()
}
