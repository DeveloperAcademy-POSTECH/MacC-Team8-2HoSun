//
//  DetailViewModel.swift
//  TwoHoSun
//
//  Created by 235 on 10/22/23.
//

import Combine
import SwiftUI

final class DetailViewModel: ObservableObject {
    @Published var postDetailData: PostDetailModel?
    var agreeTopConsumerTypes = [ConsumerType]()
    var disagreeTopConsumerTypes = [ConsumerType]()
    var commentsDatas = [CommentsModel]()
    var isSendMessage = false
    private let apiManager: NewApiManager
    var cancellables: Set<AnyCancellable> = []

    init(apiManager: NewApiManager) {
        self.apiManager = apiManager
    }

    var voteCount: Int {
        postDetailData?.post.voteCount ?? 0
    }

    var agreeCount: Int {
        postDetailData?.post.voteCounts?.agreeCount ?? 0
    }

    var disagreeCount: Int {
        postDetailData?.post.voteCounts?.disagreeCount ?? 0
    }

    var agreeRatio: Double {
        guard voteCount != 0 else {
            return 0.0
        }
        return Double(agreeCount) / Double(voteCount) * 100
    }

    var disagreeRatio: Double {
        guard voteCount != 0 else {
            return 0.0
        }
        return Double(disagreeCount) / Double(voteCount) * 100
    }

    var isAgreeHigher: Bool {
        agreeRatio > disagreeRatio
    }

//    func updatedatePostData() {
//        guard let postDetailData = postDetailData else { return }
//        postData.myChoice = postDetailData.post.myChoice
//        postData.voteCount = postDetailData.post.voteCount
//        postData.voteCounts = postDetailData.post.voteCounts
//    }

    func calculateVoteRatio(voteCount: Int,
                            agreeCount: Int,
                            disagreeCount: Int) -> (agree: Double, disagree: Double) {
        guard voteCount != 0 else { return (0, 0)}
        let agreeVoteRatio = Double(agreeCount) / Double(voteCount) * 100
        return (agreeVoteRatio, 100.0 - agreeVoteRatio)
    }

    func fetchPostDetail(postId: Int) {
        apiManager.request(.postService(.getPostDetail(postId: postId)),
                           decodingType: PostDetailModel.self)
            .compactMap(\.data)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    print(failure)
                }
            } receiveValue: { data in
                self.postDetailData = data
                self.setTopConsumerTypes()
//                self.updatedatePostData()
            }
            .store(in: &cancellables)
    }

    func votePost(postId: Int, choice: Bool) {
        apiManager.request(.postService(.votePost(postId: postId, choice: choice)),
                           decodingType: VoteCountsModel.self)
        .compactMap(\.data)
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let failure):
                print(failure)
            }
        } receiveValue: { data in
            print(data)
        }
        .store(in: &cancellables)

        fetchPostDetail(postId: postId)
    }

    private func setTopConsumerTypes() {
        guard let voteInfoList = postDetailData?.post.voteInfoList else { return }
        let (agreeVoteInfos, disagreeVoteInfos) = filterSelectedResult(voteInfoList: voteInfoList)
        agreeTopConsumerTypes = getTopConsumerTypes(for: agreeVoteInfos)
        disagreeTopConsumerTypes = getTopConsumerTypes(for: disagreeVoteInfos)
    }

    func filterSelectedResult(voteInfoList: [VoteInfoModel]) -> (agree: [VoteInfoModel],
                                                                disagree: [VoteInfoModel]) {
        return (voteInfoList.filter { $0.isAgree }, voteInfoList.filter { !$0.isAgree })
    }

    func getTopConsumerTypes(for votes: [VoteInfoModel]) -> [ConsumerType] {
        return Dictionary(grouping: votes, by: { $0.consumerType })
            .sorted { $0.value.count > $1.value.count }
            .prefix(2)
            .map { ConsumerType(rawValue: $0.key) }
            .compactMap { $0 }
    }
}
