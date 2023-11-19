//
//  PostService.swift
//  TwoHoSun
//
//  Created by 김민 on 11/13/23.
//

import UIKit

import Moya

enum PostService {
    case getPosts(page: Int, size: Int, visibilityScope: String)
    case createPost(post: PostCreateModel)
    case getPostDetail(postId: Int)
    case modifyPost
    case deletePost
    case getReviewDetail
    case modifyReview
    case createReview
    case deleteReview
    case subscribeReview
    case votePost(postId: Int, choice: Bool)
    case getSearchResult
    case getMyPosts(page: Int,
                    size: Int,
                    myVoteCategoryType: String)
    case getReviews(visibilityScope: String)
    case getMoreReviews(visibilityScope: String,
                        page: Int,
                        size: Int,
                        reviewType: String)
}

extension PostService: TargetType {
    
    var baseURL: URL {
        return URL(string: "\(URLConst.baseURL)/api")!
    }
    
    var path: String {
        switch self {
        case .getPosts:
            return "/posts"
        case .getPostDetail(let postId):
            return "/posts/\(postId)"
        case .createPost:
            return "/posts"
        case .votePost(let postId, _):
            return "/posts/\(postId)/votes"
        case .getMyPosts:
            return "mypage/posts"
        case .getReviews:
            return "/reviews"
        case .getMoreReviews(_, _, _, let reviewType):
            return "reviews/\(reviewType)"
        default:
            return ""
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .getPosts(let page, let size, let visibilityScope):
            return ["page": page,
                    "size": size,
                    "visibilityScope": visibilityScope]
        case .votePost(_, let choice):
            return ["choice": choice]
        case .getMyPosts(let page, let size, let myVoteCategoryType):
            return ["page": page,
                    "size": size,
                    "myVoteCategoryType": myVoteCategoryType]
        case .getMoreReviews(let visibilityScope,
                             let page,
                             let size,
                             let reviewType):
            return ["visibilityScope": visibilityScope,
                    "page": page,
                    "size": size,
                    "reviewType": reviewType]
        default:
            return [:]
        }
    }

    var method: Moya.Method {
        switch self {
        case .getPosts:
            return .get
        case .createPost:
            return .post
        case .getMyPosts:
            return .get
        case .getPostDetail:
            return .get
        case .votePost:
            return .post
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getPosts:
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.queryString)
        case .createPost(let post):
            var formData: [MultipartFormData] = []
            if let data = UIImage(data: post.image ?? Data())?.jpegData(compressionQuality: 0.3) {
                let imageData = MultipartFormData(provider: .data(data), name: "imageFile", fileName: "temp.jpg", mimeType: "image/jpeg")
                formData.append(imageData)
            }
            let postData: [String: Any] = [
                "visibilityScope": post.visibilityScope.rawValue,
                "title": post.title,
                "price": post.price ?? 0,
                "contents": post.contents ?? "",
                "externalURL": post.externalURL ?? ""
            ]
            do {
                let json = try JSONSerialization.data(withJSONObject: postData)
                let jsonString = String(data: json, encoding: .utf8)!
                let stringData = MultipartFormData(provider: .data(jsonString.data(using: String.Encoding.utf8)!), 
                                                   name: "postRequest",
                                                   mimeType: "application/json")
                formData.append(stringData)
            } catch {
                print("error: \(error)")
            }
            return .uploadMultipart(formData)
        case .getPostDetail(let postId):
            return .requestParameters(parameters: ["postId": postId],
                                      encoding: URLEncoding.queryString)
        case .votePost(let postId, let choice):
            return .requestCompositeParameters(bodyParameters: ["myChoice": choice],
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: ["postId": postId])
        case .getMyPosts:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getReviews(let scope):
            return .requestParameters(parameters: ["visibilitySccope": scope],
                                      encoding: URLEncoding.queryString)
        case .getMoreReviews:
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .createPost:
            APIConstants.headerMultiPartForm
        case .getMyPosts:
            APIConstants.headerWithAuthorization
        default:
            APIConstants.headerWithAuthorization
        }
    }
}
