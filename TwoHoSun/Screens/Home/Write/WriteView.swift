//
//  WriteVIew.swift
//  TwoHoSun
//
//  Created by 235 on 10/19/23.
//

import SwiftUI

struct WriteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var content = ""
    @State private var placeholderText = "욕설,비방,광고 등 소비 고민과 관련없는 내용은 통보 없이 삭제될 수 있습니다."
    @State private var contentTextCount = 0
    @State private var voteDeadlineValue = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                titleView
                    .padding(.top, 24)
                tagView
                    .padding(.top, 32)
                addImageView
                    .padding(.top, 30)
                voteDeadlineView
                    .padding(.top, 32)
                contentView
                    .padding(.top, 32)
            }
            .padding(.horizontal, 26)
        }
        .navigationTitle("소비고민 등록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }
}

extension WriteView {

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 20))
                .foregroundStyle(.gray)
        }
    }

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerLabel("제목을 입력해주세요. ", "(필수)")
            HStack {
                roundedTextField(
                    Text("한/영 15자 이내(물품)")
                    .font(.system(size: 14)),
                                 cornerRadius: 10
                )
                titleCategory
            }
        }
    }

    private var titleCategory: some View {
        HStack(spacing: 9) {
            Text("살까 말까")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.gray)
                .frame(height: 44)
                .padding(.leading, 16)
            Button {

            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
                    .padding(.trailing, 12 )
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 1)
        }
    }

    private var tagView: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerLabel("태그를 선택해 주세요. ", "(최대 3개 태그 선택 가능)")
            HStack {
                addTagButton
                Spacer()
            }
        }
    }

    private var addTagButton: some View {
        Button {
            print("add tag button did tap!")
        } label: {
            ZStack {
                Circle()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.gray)
                Image(systemName: "plus")
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
            }
        }
    }

    private var addImageView: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerLabel("고민하는 상품 사진을 등록해 주세요. ", "(최대 4개)")
            addImageButton
                .padding(.top, 12)
                .padding(.bottom, 10)
            addLinkButton
        }
    }

    private var addImageButton: some View {
        Button {
            print("add image button did tap!")
        } label: {
            HStack(spacing: 7) {
                Spacer()
                Image(systemName: "plus")
                    .font(.system(size: 16))
                Text("상품 이미지")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
            }
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.gray)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(.gray, lineWidth: 1)
            }
        }
    }

    private var addLinkButton: some View {
        roundedTextField(
            Text("링크 주소 입력하기 ")
                .font(.system(size: 14, weight: .medium)) +
            Text("(선택)")
                .font(.system(size: 12, weight: .medium)), 
            cornerRadius: 5
        )
    }

    private var voteDeadlineView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("투표 종료일을 선택해 주세요.")
                .font(.system(size: 16, weight: .semibold))
            voteSlider
        }
    }

    private var voteSlider: some View {
        VStack(spacing: 10) {
            Slider(value: $voteDeadlineValue)
                .onChange(of: voteDeadlineValue) { _, newValue in
                    let stepSize: Double = 0.166
                    let roundedValue = round(newValue / stepSize) * stepSize
                    voteDeadlineValue = min(roundedValue, 1.0)
                }
                .tint(.gray)
            HStack {
                Text("1일")
                Spacer()
                Text("2일")
                Spacer()
                Text("3일")
                Spacer()
                Text("4일")
                Spacer()
                Text("5일")
                Spacer()
                Text("6일")
                Spacer()
                Text("7일")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.gray)
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerLabel("내용을 작성해 주세요. ", "(선택)")
            textView
        }
    }

    private var textView: some View {
        ZStack(alignment: .bottomTrailing) {
            if content.isEmpty {
                TextEditor(text: $placeholderText)
                    .foregroundStyle(.gray)
            }
            TextEditor(text: $content)
              .opacity(self.content.isEmpty ? 0.25 : 1)
            contentTextCountView
                .padding(.trailing, 15)
                .padding(.bottom, 14)
        }
        .font(.system(size: 14, weight: .medium))
        .frame(height: 109)
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(.gray, lineWidth: 1)
        }
    }

    private var contentTextCountView: some View {
        Text("\(content.count) ")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.black) +
        Text("/ 100")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.gray)
    }

    private func headerLabel(_ title: String, _ description: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold)) +
        Text(description)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.gray)
    }

    private func roundedTextField(_ prompt: Text, cornerRadius: CGFloat) -> some View {
        HStack(spacing: 0) {
            prompt
                .foregroundStyle(.gray)
                .frame(height: 46)
                .padding(.leading, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.gray, lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        WriteView()
    }
}