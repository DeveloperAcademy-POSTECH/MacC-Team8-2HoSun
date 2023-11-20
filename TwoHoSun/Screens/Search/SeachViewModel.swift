//
//  SeachViewModel.swift
//  TwoHoSun
//
//  Created by 김민 on 10/23/23.
//
import Combine
import Foundation


final class SearchViewModel: ObservableObject {
    @Published var searchHistory = [String]()
    var isFetching = false
    @Published var searchedDatas: [SummaryPostModel] = [] {
        didSet {
            print("사리추가요")
        }
    }
    private var apiManager: NewApiManager
    @Published var selectedFilterType = PostStatus.active
    @Published var page = 0
    var selectedVisibilityScope: VisibilityScopeType
    private var bag = Set<AnyCancellable>()
    init(apiManager: NewApiManager, selectedVisibilityScope: VisibilityScopeType) {
        self.apiManager = apiManager
        self.selectedVisibilityScope = selectedVisibilityScope
        fetchRecentSearch()
    }

    func fetchRecentSearch() {
        guard let recentSearch = UserDefaults.standard.array(forKey: "RecentSearch") as? [String] else { return }
        searchHistory = recentSearch
    }

    func addRecentSearch(searchWord: String) {
        searchHistory.insert(searchWord, at: 0)
        if searchHistory.count > 12 {
            searchHistory.removeLast()
        }
        setRecentSearch()
    }

    func removeRecentSearch(at index: Int) {
        searchHistory.remove(at: index)
        setRecentSearch()
    }

    func removeAllRecentSearch() {
        searchHistory.removeAll()
        setRecentSearch()
    }

    func setRecentSearch() {
        UserDefaults.standard.set(searchHistory, forKey: "RecentSearch")
    }
    // TODO: - fetching result data
    func fetchSearchedData(size: Int = 5, keyword: String) {
        isFetching = true
        var cancellable: AnyCancellable?
        cancellable =  apiManager.request(.postService(
            .getSearchResult(postStatus: selectedFilterType,
                             visibilityScopeType: selectedVisibilityScope,
                             page: page, size: size, keyword: keyword)),
                           decodingType: [SummaryPostModel].self)
        .compactMap(\.data)
        .sink { completion in
            print(completion)
        } receiveValue: { data in
            self.searchedDatas.append(contentsOf: data)
            self.isFetching = false
            self.addRecentSearch(searchWord: keyword)
            self.page += 1
            cancellable?.cancel()
        }
    }
}
