//
//  SearchView.swift
//  TwoHoSun
//
//  Created by 관식 on 10/21/23.
//

import SwiftUI

enum SearchFilterType: Int, CaseIterable {
    case progressing, end, review

    var filterTitle: String {
        switch self {
        case .progressing:
            return "진행중인 투표"
        case .end:
            return "종료된 투표"
        case .review:
            return "후기"
        }
    }
}

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var hasResult: Bool = false
    @State private var isSearchResultViewShown = false
    @State private var selectedFilterType = SearchFilterType.progressing
    @State private var searchTextFieldState = SearchTextFieldState.inactive
    @FocusState private var isFocused: Bool
    private let viewModel = SearchViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            Color.background
                .ignoresSafeArea()
            VStack( spacing: 0) {
                HStack(spacing: 8) {
                    backButton
                    searchField
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 8)
                VStack(alignment: .leading) {
                    if isSearchResultViewShown {
                        searchFilterView
                            .padding(.bottom, 24)
                        searchResultView
                    } else {
                        HStack {
                            recentSearchLabel
                            Spacer()
                            deleteAllButton
                        }
                        recentSearchView
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension SearchView {

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.accentBlue)
        }
    }

    private var searchField: some View {
        HStack {
            TextField("search",
                      text: $searchText,
                      prompt: Text("원하는 소비항목을 검색해보세요.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.placeholderGray))
                .focused($isFocused)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(searchTextFieldState.foregroundColor)
                .tint(Color.placeholderGray)
                .frame(height: 32)
                .padding(.leading, 16)
                .onChange(of: isFocused) { _, isFocused in
                    if isFocused {
                        searchTextFieldState = .active
                    }
                }
                .onSubmit {
                    searchTextFieldState = .submitted
                    isSearchResultViewShown = true
                    viewModel.addRecentSearch(searchWord: searchText)
                }
            Spacer()
            Button {
                searchText.removeAll()
                searchTextFieldState = .active
                isFocused = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.subGray2)
                    .padding(.trailing, 16)
            }
        }
        .background(searchTextFieldState.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            if searchTextFieldState == .active {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(searchTextFieldState.strokeColor, lineWidth: 1)
                    .blur(radius: 3)
                    .shadow(color: Color.shadowBlue, radius: 2)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(searchTextFieldState.strokeColor, lineWidth: 1)
        }
        .frame(height: 32)
    }

    private var recentSearchLabel: some View {
        Text("최근 검색")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
    }

    private var deleteAllButton: some View {
        Button {
            viewModel.removeAllRecentSearch()
        } label: {
            Text("전체 삭제")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.darkGray)
        }
    }

    private func recentSearchCell(word: String, index: Int) -> some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .strokeBorder(Color.purpleStroke, lineWidth: 1)
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.clear)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color.darkGray)
            }
            Text(word)
                .font(.system(size: 16))
                .foregroundStyle(Color.woteWhite)
                .padding(.leading, 16)
            Spacer()
            Button {
                viewModel.removeRecentSearch(at: index)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.darkGray)
            }
        }
    }

    private var recentSearchView: some View {
        List {
            ForEach(viewModel.searchWords.indices, id: \.self) { index in
                recentSearchCell(word: viewModel.searchWords[index], index: index)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }

    private var searchFilterView: some View {
        HStack(spacing: 8) {
            ForEach(SearchFilterType.allCases, id: \.self) { filter in
                FilterButton(title: filter.filterTitle,
                             isSelected: selectedFilterType == filter) {
                    selectedFilterType = filter
                }
            }
        }
    }

    private func listCell(cellType: some View, destination: some View) -> some View {
        ZStack {
            cellType
            NavigationLink(destination: destination) { }
                .opacity(0.0)
        }
    }

    private var searchResultView: some View {
        ScrollViewReader { proxy in
            List {
                switch selectedFilterType {
                case .progressing:
                    ForEach(0..<5) { _ in
//                        listCell(cellType: VoteCardCell(cellType: .standard,
//                                                        progressType: .progressing,
//                                                        post: )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                    .id("searchResult")
                case .end:
                    ForEach(0..<5) { _ in
//                        listCell(cellType: VoteCardCell(cellType: .standard,
//                                                        progressType: .end,
//                                                        voteResultType: .draw,
//                                                        post: )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                    .id("searchResult")
                case .review:
                    ForEach(0..<5) { _ in
                        listCell(cellType: ReviewCardCell(cellType: .search, isPurchased: false),
                                 destination: ReviewDetailView())
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                    .id("searchResult")
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .onChange(of: selectedFilterType) { _, _ in
                proxy.scrollTo("searchResult", anchor: .top)
            }
        }
    }

    private var emptyResultView: some View {
        VStack(spacing: 20) {
            Image("imgNoResult")
            Text("검색 결과가 없습니다.")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.subGray1)
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
