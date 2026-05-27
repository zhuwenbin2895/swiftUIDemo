import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("异步渲染") {
                    NavigationLink {
                        AsyncRenderDemoView()
                    } label: {
                        Label("AsyncRender", systemImage: "bolt.horizontal.circle")
                    }
                }
                Section("布局引擎") {
                    NavigationLink {
                        TangramKitDemoView()
                    } label: {
                        Label("TangramKit", systemImage: "square.3.layers.3d.down.right")
                    }
                }
                Section("UI组件库") {
                    NavigationLink {
                        QMUIKitDemoView()
                    } label: {
                        Label("QMUIKit", systemImage: "paintbrush")
                    }
                }
                Section("QMUI_iOS") {
                    NavigationLink {
                        FloatingPopoverDemoView()
                    } label: {
                        Label("FloatingPopover", systemImage: "bubble.left.and.bubble.right")
                    }
                    NavigationLink {
                        TableViewDemoView()
                    } label: {
                        Label("TableView", systemImage: "tablecells")
                    }
                    NavigationLink {
                        ImagePickerDemoView()
                    } label: {
                        Label("ImagePicker", systemImage: "photo.stack")
                    }
                    NavigationLink {
                        ConsoleDemoView()
                    } label: {
                        Label("Console", systemImage: "terminal")
                    }
                    NavigationLink {
                        KeyboardManagerDemoView()
                    } label: {
                        Label("KeyboardManager", systemImage: "keyboard")
                    }
                    NavigationLink {
                        RuntimeToolsDemoView()
                    } label: {
                        Label("RuntimeTools", systemImage: "gearshape.2")
                    }
                }
                Section("TabBar组件") {
                    NavigationLink {
                        CYLTabBarDemoView()
                    } label: {
                        Label("CYLTabBar", systemImage: "square.split.1x2")
                    }
                }
                Section("菜单组件") {
                    NavigationLink {
                        DropDownMenuDemoView()
                    } label: {
                        Label("DropDownMenu", systemImage: "list.bullet.below.rectangle")
                    }
                }
                Section("轮播组件") {
                    NavigationLink {
                        iCarouselDemoView()
                    } label: {
                        Label("iCarousel", systemImage: "rectangle.3.group")
                    }
                }
                Section("卡片组件") {
                    NavigationLink {
                        KolodaDemoView()
                    } label: {
                        Label("KolodaCards", systemImage: "rectangle.stack.fill")
                    }
                }
                Section("树形组件") {
                    NavigationLink {
                        TreeViewDemoView()
                    } label: {
                        Label("TreeView", systemImage: "list.triangle")
                    }
                }
                Section("评分组件") {
                    NavigationLink {
                        StarRatingDemoView()
                    } label: {
                        Label("StarRating", systemImage: "star.leadinghalf.filled")
                    }
                }
                Section("二维码组件") {
                    NavigationLink {
                        QRCodeDemoView()
                    } label: {
                        Label("QRCodeKit", systemImage: "qrcode")
                    }
                }
                Section("组件演示") {
                    NavigationLink {
                        SkeletonViewDemoView()
                    } label: {
                        Label("SkeletonView", systemImage: "rectangle.on.rectangle.angled")
                    }
                    NavigationLink {
                        SearchKitDemoView()
                    } label: {
                        Label("SearchKit", systemImage: "magnifyingglass")
                    }
                    NavigationLink {
                        CalendarDemoView()
                    } label: {
                        Label("CalendarKit", systemImage: "calendar")
                    }
                    NavigationLink {
                        ProgressHUDDemoView()
                    } label: {
                        Label("ProgressHUD", systemImage: "circles.hexagonpath")
                    }
                    NavigationLink {
                        RefreshableListDemoView()
                    } label: {
                        Label("RefreshableList", systemImage: "arrow.up.arrow.down.circle")
                    }
                    NavigationLink {
                        DraggableGridDemoView()
                    } label: {
                        Label("DraggableGrid", systemImage: "square.grid.3x3")
                    }
                    NavigationLink {
                        PopupDemoView()
                    } label: {
                        Label("CustomPopup", systemImage: "rectangle.on.rectangle")
                    }
                    NavigationLink {
                        TagSelectorDemoView()
                    } label: {
                        Label("TagSelector", systemImage: "tag")
                    }
                    NavigationLink {
                        ChartDemoView()
                    } label: {
                        Label("ChartKit", systemImage: "chart.bar.xaxis")
                    }
                }
            }
            .navigationTitle("SwiftUI Demo")
        }
    }
}

#Preview {
    ContentView()
}
