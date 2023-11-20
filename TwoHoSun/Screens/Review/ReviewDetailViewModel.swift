//
//  ReviewDetailViewModel.swift
//  TwoHoSun
//
//  Created by 김민 on 11/20/23.
//

import Combine
import SwiftUI

@Observable
final class ReviewDetailViewModel {
    var reviewData: ReviewDetailModel?
    private var apiManager: NewApiManager
    private var cancellable = Set<AnyCancellable>()

    init(apiManager: NewApiManager) {
        self.apiManager = apiManager
    }

    func fetchReviewDetail(id: Int) {
        apiManager.request(.postService(.getReviewDetail(reviewId: id)),
                           decodingType: ReviewDetailModel.self)
        .compactMap(\.data)
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let failure):
                print(failure)
            }
        } receiveValue: { data in
            self.reviewData = data
        }
        .store(in: &cancellable)
    }
}
