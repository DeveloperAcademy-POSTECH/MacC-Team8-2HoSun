//
//  ProfileSettingsView.swift
//  TwoHoSun
//
//  Created by 김민 on 10/16/23.
//

import PhotosUI
import SwiftUI

enum NicknameValidationType {
    case none, empty, length, forbiddenWord, duplicated, valid

    var alertMessage: String {
        switch self {
        case .none:
            return ""
        case .empty:
            return "닉네임을 입력해주세요."
        case .length:
            return "닉네임은 1~10자로 설정해주세요."
        case .forbiddenWord:
            return "해당 닉네임으로는 아이디를 생성할 수 없어요."
        case .duplicated:
            return "중복된 닉네임입니다."
        case .valid:
            return "사용 가능한 닉네임입니다."
        }
    }

    var alertMessageColor: Color {
        switch self {
        case .none:
            return .clear
        case .valid:
            return Color.deepBlue
        default:
            return Color.errorRed
        }
    }

    var textfieldBorderColor: Color {
        switch self {
        case .none, .valid:
            return Color.grayStroke
        default:
            return Color.errorRed
        }
    }
}

enum ProfileInputType {
    case nickname, school

    var iconName: String {
        switch self {
        case .nickname:
            return ""
        case .school:
            return "magnifyingglass"
        }
    }

    var placeholder: String {
        switch self {
        case .nickname:
            return "한/영 10자 이내(특수문자 불가)"
        case .school:
            return "학교를 검색해주세요."
        }
    }

    var alertMessage: String {
        switch self {
        case .nickname:
            return "닉네임을 입력해주세요."
        case .school:
            return "학교를 입력해주세요."
        }
    }
}

enum ProfileSettingType {
    case setting, modfiy
}

struct ProfileSettingsView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    //    @State private var selectedImageData: Data?
    @State private var isProfileSheetShowed = false
    @State private var retryProfileImage = false
    @State var viewType: ProfileSettingType
    @Bindable var viewModel: ProfileSettingViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack(spacing: 0) {
                switch viewType {
                case .setting:
                    titleLabel
                        .padding(.top, 40)
                case .modfiy:
                    HStack {
                        SpendTypeLabel(spendType: .impulseBuyer, usage: .standard)
                        Spacer()
                    }
                    .padding(.top, 30)
                }
                Spacer()
                profileImage
                Spacer()
                nicknameInputView
                    .padding(.bottom, 34)
                schoolInputView
                Spacer()
                switch viewType {
                case .setting:
                    nextButton
                case .modfiy:
                    // TODO: - 테스트 1회 다시하기 로직 추가 필요
                    goToTypeTestButton
                        .padding(.bottom, 12)
                    completeButton
                }
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
        }
        .onTapGesture {
            endTextEditing()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewType == .setting ? true : false)
        .toolbar {
            if viewType == .modfiy {
                ToolbarItem(placement: .principal) {
                    Text("프로필 수정")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .toolbarBackground(Color.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .photosPicker(isPresented: $retryProfileImage, selection: $selectedPhoto)
        .customConfirmDialog(isPresented: $isProfileSheetShowed) {
            Button("프로필 삭제하기", role: .destructive) {
                selectedPhoto = nil
                viewModel.selectedImageData = nil
                isProfileSheetShowed.toggle()
            }
            .frame(height: 42)
            Divider()
            Button("프로필 재설정하기") {
                retryProfileImage = true
            }
            .frame(height: 42)
            .navigationTitle("프로필 설정")
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden()
        }
        //        .onChange(of: viewModel.isSucccedPost) { _, newValue in
        //            if newValue == true {
        //                navigationPath.removeFirst()
        //                navigationPath.append(.mainTabView)
        //                print(navigationPath)
        //            }
        //        }
    }
}

extension ProfileSettingsView {

    // MARK: - UI Components

    private var titleLabel: some View {
        HStack(spacing: 7) {
            VStack(alignment: .leading, spacing: 9) {
                Image("logo")
                    .resizable()
                    .frame(width: 86, height: 28)
                Text("설정해")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color.white)
            }
            VStack(alignment: .leading) {
                Text("프로필")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.white) +
                Text("을")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color.white)
                Text("주세요.")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color.white)
            }
            Spacer()
        }
    }

    private var profileImage: some View {
        ZStack(alignment: .bottomTrailing) {
            if let selectedData = viewModel.selectedImageData,
               let uiImage = UIImage(data: selectedData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
            } else {
                photoPickerView {
                    Image("defaultProfile")
                        .resizable()
                        .frame(width: 130, height: 130)
                }
            }
            selectProfileButton
        }
        .onTapGesture {
            if viewModel.selectedImageData != nil {
                isProfileSheetShowed = true
            }
        }
    }

    private var selectProfileButton: some View {
        ZStack {
            Circle()
                .frame(width: 34, height: 34)
                .foregroundStyle(Color.lightBlue)
            Image(systemName: "plus")
                .font(.system(size: 20))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    func photoPickerView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        PhotosPicker(selection: $selectedPhoto,
                     matching: .images,
                     photoLibrary: .shared()) {
            content()
                .onChange(of: selectedPhoto) { _, newValue in
                    PHPhotoLibrary.requestAuthorization { status in
                        guard status == .authorized else { return }
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                viewModel.selectedImageData = data
                            }
                        }
                    }
                }
        }
    }

    private var nicknameInputView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("닉네임")
                .modifier(TitleTextStyle())
            HStack(spacing: 10) {
                TextField("",
                          text: $viewModel.nickname,
                          prompt: Text(ProfileInputType.nickname.placeholder)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.placeholderGray))
                .foregroundStyle(Color.white)
                .frame(height: 44)
                .padding(EdgeInsets(top: 0, leading: 17, bottom: 0, trailing: 0))
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(viewModel.nicknameValidationType.textfieldBorderColor, lineWidth: 1)
                        if (viewModel.nicknameValidationType == .none || viewModel.nicknameValidationType == .valid) {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(viewModel.nicknameValidationType.textfieldBorderColor, lineWidth: 1)
                                .shadow(color: Color.strokeBlue.opacity(0.15), radius: 2)
                                .blur(radius: 3)
                        }
                    }
                }
                .onChange(of: viewModel.nickname) { _, newValue in
                    viewModel.checkNicknameValidation(newValue)
                }
                checkDuplicatedIdButton
            }

            if viewModel.nicknameValidationType != .none {
                nicknameValidationAlertMessage(for: viewModel.nicknameValidationType)
                    .padding(.top, 6)
            }
        }
    }

    private var checkDuplicatedIdButton: some View {
        Button {
            viewModel.postNickname()
            if viewModel.nicknameValidationType == .valid {
                endTextEditing()
            }
        } label: {
            Text("중복확인")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 103, height: 44)
                .background(Color.disableGray)
                .cornerRadius(10)
        }
        .disabled(viewModel.nicknameValidationType == .length)
    }

    private var schoolInputView: some View {
        NavigationLink {
            SchoolSearchView(selectedSchoolInfo: $viewModel.selectedSchoolInfo)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text("우리 학교")
                    .modifier(TitleTextStyle())
                roundedIconTextField(for: .school,
                                     text: viewModel.selectedSchoolInfo?.school.schoolName,
                                     isFilled: viewModel.isSchoolFilled)
                if !viewModel.isFormValid && !viewModel.isSchoolFilled {
                    schoolValidationAlertMessage
                        .padding(.top, 6)
                }
            }
        }
    }

    private var nextButton: some View {
        Button {
            guard viewModel.isAllInputValid else {
                viewModel.setInvalidCondition()
                return
            }
            viewModel.setProfile()
        } label: {
            Text("완료")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 361, height: 52)
                .background(viewModel.isAllInputValid ? Color.lightBlue : Color.disableGray)
                .cornerRadius(10)
        }
        .disabled(viewModel.isAllInputValid ? false : true)
    }

    private var completeButton: some View {
        Button {
            guard viewModel.isAllInputValid else {
                viewModel.setInvalidCondition()
                return
            }
            // TODO: - fetch modify profile api
            dismiss()
        } label: {
            Text("완료")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 361, height: 52)
                .background(viewModel.isAllInputValid ? Color.lightBlue : Color.disableGray)
                .cornerRadius(10)
        }
        .disabled(viewModel.isAllInputValid ? false : true)
    }

    private func roundedIconTextField(for input: ProfileInputType, text: String?, isFilled: Bool) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                Text(text ?? input.placeholder)
                    .font(.system(size: 14))
                    .foregroundColor(text != nil ? .white : Color.placeholderGray)
                    .frame(height: 45)
                    .padding(.leading, 17)
                Spacer()
                Image(systemName: input.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.placeholderGray)
                    .padding(.trailing, 12)
            }
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(!isFilled && !viewModel.isFormValid ? Color.errorRed : Color.grayStroke, lineWidth: 1)
            }
        }
    }

    private var goToTypeTestButton: some View {
        NavigationLink {
            TypeTestIntroView()
        } label: {
            HStack(spacing: 0) {
                Text("소비 성향 테스트하러가기")
                    .foregroundStyle(.white)
                Text("(1회)")
                    .foregroundStyle(Color.gray500)
            }
            .font(.system(size: 16, weight: .semibold))
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(Color.lightBlue)
            .clipShape(.rect(cornerRadius: 10))
        }
    }

    private func nicknameValidationAlertMessage(for input: NicknameValidationType) -> some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.nicknameValidationType == .valid ?
                  "checkmark.circle.fill" : "light.beacon.max")
            Text(input.alertMessage)
            Spacer()
        }
        .font(.system(size: 12))
        .foregroundStyle(viewModel.nicknameValidationType.alertMessageColor)
    }

    private var schoolValidationAlertMessage: some View {
        HStack(spacing: 8) {
            Image(systemName: "light.beacon.max")
            Text(ProfileInputType.school.alertMessage)
            Spacer()
        }
        .font(.system(size: 12))
        .foregroundStyle(Color.errorRed)
    }

    struct TitleTextStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.white)
                .padding(.bottom, 8)
        }
    }
}

#Preview {
    ProfileSettingsView(viewType: .setting,
                        viewModel: ProfileSettingViewModel(path: .constant([])))
}
