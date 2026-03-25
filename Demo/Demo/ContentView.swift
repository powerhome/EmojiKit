//
//  ContentView.swift
//  Demo
//
//  Created by Daniel Saidi on 2024-06-07.
//  Copyright © 2024-2026 Daniel Saidi. All rights reserved.
//

import EmojiKit
import SwiftUI
import SwiftUIKit

struct ContentView: View {
    
    @FocusState var isFocused

    @State private var query = ""
    @State private var sizeMode = SizeMode.medium

    // Persisted Category - Uncomment to use this **********

//    @AppStorage("com.danielsaidi.emojikit.demo.category")
//    private var categoryValue: StorageValue<EmojiCategory> = .init()
//
//    @State private var selection: Emoji.GridSelection?
//
//    private var category: EmojiCategory? { categoryValue.value }
//    private var categoryBinding: Binding<EmojiCategory?> { $categoryValue.value }
//    private var selectionBinding: Binding<Emoji.GridSelection?> { $selection }

    // Persisted Selection - Uncomment to use this *********

    @AppStorage("com.danielsaidi.emojikit.demo.selection")
    private var selectionValue: StorageValue<Emoji.GridSelection> = .init()
    @State private var category: EmojiCategory?

    private var categoryBinding: Binding<EmojiCategory?> { $category }
    private var selectionBinding: Binding<Emoji.GridSelection?> { $selectionValue.value }
    
    private let categories: [EmojiCategory] = [.recent] + .standard

    var body: some View {
        VStack {
          searchView

          EmojiGridScrollView(
            categories: categories,
            category: categoryBinding,
            selection: selectionBinding,
            query: query,
            action: { _ in
            },
            sectionTitle: { $0.view },
            gridItem: { $0.view }
          )

          categoryFooterView
        }
        .background(Color.white)
    }
    
    private var searchView: some View {
      HStack {
        TextField("Search", text: $query)
          .textInputAutocapitalization(.none)
          .disableAutocorrection(true)
          .foregroundStyle(.primary)
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 10)
      .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
      )
      .padding(.horizontal)
      .padding(.top, 8)
    }
    
    private var categoryFooterView: some View {
      HStack {
        ForEach(categories) { item in
          Button {
            if category != item {
                category = item
              query = ""
            }
          } label: {
            Image(systemName: item.symbolIconName)
                  .foregroundColor(category == item ? .blue : .gray)
          }
          .frame(maxWidth: 16, maxHeight: 16)
          .padding(.horizontal, 8)
          .padding(.vertical, 8)
        }
        
        Spacer()
      }
      .padding(.leading, 8)
      .padding(.bottom, 8)
    }
}

private extension ContentView {

    enum SizeMode: String, CaseIterable, Identifiable {

        case small, medium, large, extraLarge, extraExtraLarge

        var id: String { rawValue }

        var gridStyle: EmojiGridStyle {
            switch self {
            case .small: .small
            case .medium: .medium
            case .large: .large
            case .extraLarge: .extraLarge
            case .extraExtraLarge: .extraExtraLarge
            }
        }
    }
}

private extension ContentView {

    var categoryLabel: some View {
        let symbol = category?.symbolIconName ?? "face.smiling"
        return Label("Categories", systemImage: symbol)
    }

    var categoryPicker: some View {
        let symbol = category?.symbolIconName ?? "face.smiling"
        return ToolbarPicker(title: "Category", image: symbol, selection: categoryBinding) {
            ForEach(EmojiCategory.standardCategories) {
                $0.label.tag($0)
            }
        }
        .labelStyle(.iconOnly)
    }

    var sizePicker: some View {
        ToolbarPicker(title: "Size", image: "square.resize", selection: $sizeMode) {
            ForEach(SizeMode.allCases) {
                Text($0.rawValue.camelCaseAsDisplayName())
                    .tag($0)
            }
        }
        .labelStyle(.iconOnly)
    }
}

struct ToolbarPicker<Value: Hashable, Content: View>: View {

    let title: String
    let image: String
    let selection: Binding<Value>
    let content: () -> Content

    var body: some View {
        Menu {
            Picker(title, selection: selection) {
                content()
            }
            .pickerStyle(.inline)
        } label: {
            Label(title, systemImage: image)
        }
    }
}

extension View {
    @ViewBuilder
    func glassEffectIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect()
        } else {
            self
        }
    }
}

extension String {

    func camelCaseAsDisplayName() -> String {
        replacingOccurrences(
            of: "([a-z])([A-Z])",
            with: "$1 $2",
            options: .regularExpression
        )
        .capitalized
    }
}

#Preview {
    ContentView()
}
