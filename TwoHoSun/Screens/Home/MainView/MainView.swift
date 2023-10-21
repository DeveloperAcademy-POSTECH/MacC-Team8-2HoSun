//
//  HomeView.swift
//  TwoHoSun
//
//  Created by 관식 on 10/16/23.
//

import SwiftUI

enum MainPathType {
    case toAll
    case ourSchool
}
struct MainView: View {
    enum FilterType : CaseIterable {
        case all, popular, currentvote, finishvote
        var title: String {
            switch self {
            case .all:
                return "전체"
            case .popular:
                return "인기"
            case .currentvote:
                return "투표진행중"
            case .finishvote:
                return "종료된투표"
            }
        }
    }

    @State private var filterState: FilterType = .all
    let viewModel = MainViewModel()
    @State private var touchPlus: Bool = false
    @State private var path : [MainPathType] = []

    var body: some View {
        NavigationStack {
            if viewModel.loading {
                ProgressView("Loading")
            } else {
            ZStack(alignment: .bottomTrailing) {
                emptyView
                ScrollView {
                    LazyVStack {
                        filterBar
                        ForEach(viewModel.datalist) { data in
                            MainCellView(postData: data)
                                .onAppear {
                                    guard let index = viewModel.datalist.firstIndex(where: {$0.id == data.id}) else {return}
                                    if index % 10 == 0 && !viewModel.lastPage {
                                        viewModel.getPosts()
                                    }
                                }
                        }
                    }
                }
                floatingButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("splash")
                        .resizable()
                        .frame(width: 120,height: 36)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        noticeButton
                        searchButton
                    }
                }
            }}
        }.onAppear {
            viewModel.getPosts(30,first: true)
        }
    }

}

extension MainView {
    private var noticeButton: some View {
        NavigationLink {
            NotificationView()
        } label: {
            Image(systemName: "bell.fill")
                .font(.system(size: 16))
                .foregroundStyle(.gray)
        }
    }

    private var searchButton: some View {
        Button(action: {
            // TODO: 통합검색으로 이동하도록
        }, label: {
            Image(systemName: "magnifyingglass")
        })
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(FilterType.allCases, id: \.self) { filter in
                filterButton(filter.title)
            }
            Spacer()
        }
        .padding(.top, 30)
        .padding(.leading, 26)
    }

    private var floatingButton: some View {
        ZStack(alignment: .bottomTrailing) {
            if touchPlus {
                VStack( alignment: .leading, spacing: 14) {
                    Button {
                        path.append(.toAll)
                    } label: {
                        Text("전국 투표 올리기")
                            .font(.system(size: 14))
                            .padding(.leading,14)
                    }
                    .buttonStyle(.plain)
                    Rectangle()
                        .fill(Color.gray)
                        .opacity(0.5)
                        .frame(height: 1)
                    Button {
                        path.append(.ourSchool )
                    } label: {
                        Text("우리 학교 올리기")
                            .font(.system(size: 14))
                            .padding(.leading,14)
                    }
                    .buttonStyle(.plain)
                }
                .animation(.easeInOut(duration: 1), value: touchPlus)
                .listStyle(PlainListStyle())
                .frame(width: 145, height: 88)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1.0)
                )
                .padding(.trailing, 16)
                .offset(y: -76)
            }
            Button {
                touchPlus.toggle()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .padding(16)
                    .background(touchPlus ? Color.gray : Color.white)
                    .foregroundColor(touchPlus ? Color.white : Color.gray)
                    .clipShape(Circle())
                    .shadow(radius: 7, x: 2, y: 2)
                    .rotationEffect(Angle.degrees(touchPlus ? 45 : 0))
                    .animation(.linear(duration: 0.3), value: touchPlus)
            }
            .frame(width: 30,height: 30)
            .padding(.trailing, 26)
            .padding(.bottom, 26)
        }
    }

    @ViewBuilder
    private var emptyView: some View {
        if viewModel.datalist.isEmpty {
            VStack {
                filterBar
                Spacer()
                Image(systemName: "photo")
                Text("아직 소비고민이 없어요")
                Button {
                    touchPlus.toggle()
                } label: {
                    Text("투표하러 가기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 148, height: 52)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
        }
    }
    func filterButton(_ title: String) -> some View {
        let isSelected = filterState.title == title
        return Button {
            filterState = FilterType.allCases.first { $0.title == title } ?? .all
        } label: {
            Text(title)
                .font(.system(size: 14))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .foregroundColor(isSelected ? Color.white : Color.primary)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill( isSelected ? Color.gray : Color.clear)
                        .stroke(Color.gray, lineWidth: 1.0)
                )
        }
    }
}
#Preview {
    NavigationView {
        MainView()
    }
}
