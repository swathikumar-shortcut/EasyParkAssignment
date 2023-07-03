//
//  HomeViewModelTests.swift
//  EasyParkAssignmentTests
//
//  Created by Swathi on 2023-07-02.
//

import XCTest
@testable import EasyParkAssignment

final class HomeViewModelTests: XCTestCase {
    
    static let mockCity1 = City.mockCity1()
    static let mockCity2 = City.mockCity2()
    static let mockCountry = Countries.mock()
    
    static let dataSourceRemoteStub = FetchCountriesDataLayerStub(response: .success(mockCountry))
    static let fetchCountriesService = buildFetchCountriesRepository()
    static let fetchCountriesUseCase = FetchCountriesUseCase(source: fetchCountriesService)
   

    @MainActor
    func testHomeViewModel_onAppear_citiesArePopulated() async {
        let sut = makeSUT()
        await sut.onAppearAction()
        XCTAssertFalse(sut.cities.isEmpty)
    }
    
    @MainActor
    func testHomeViewModel_onAppearFetchRemoteFails_errorAlertCauseIsSet() async {
        let remoteErrorCause = "Remote Fetch failed"
        let errorNetworkError = NetworkingError.networkError(cause: remoteErrorCause)
        let dataSourceRemoteStubWithError = FetchCountriesDataLayerStub(response: .failure(errorNetworkError))
        let fetchCountriesSource = Self.buildFetchCountriesRepository(remoteSource: dataSourceRemoteStubWithError)
        let fetchCountriesUseCase = FetchCountriesUseCase(source: fetchCountriesSource)
        let sut = makeSUT(fetchCountriesUseCase: fetchCountriesUseCase)
        await sut.onAppearAction()
        XCTAssertEqual(sut.alertError, errorNetworkError)
    }
    
    // MARK: - Helpers
    
    @MainActor
    private func makeSUT(
        fetchCountriesUseCase: FetchCountriesUseCase = fetchCountriesUseCase,
        file: StaticString = #file,
        line: UInt = #line
    ) -> HomeViewModel {
        let sut = HomeViewModel(fetchCountries: fetchCountriesUseCase)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private static func buildFetchCountriesRepository(
        remoteSource: FetchCountriesDataSource = dataSourceRemoteStub
    ) -> FetchCountriesRepository {
        return FetchCountriesRepository(source: remoteSource)
    }

}