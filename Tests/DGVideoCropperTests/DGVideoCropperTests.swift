import Testing
@testable import DGVideoCropper

@Test func divideDurationUseCase() async throws {
    let duration: Double = 180
    let divide = 6
    let useCase = DivideDurationUseCase(duration: duration, divide: divide)
    let timeIntervals = useCase.execute()
    #expect(timeIntervals.count >= divide)
}
