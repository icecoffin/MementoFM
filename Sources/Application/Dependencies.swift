//
//  Dependencies.swift
//  MementoFM
//
//  Created by Daniel on 28/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Combine
import Persistence
import Networking
import Onboarding
import Sync
import TransientModels
import SharedServicesInterface
import SharedServices

struct AppDependency: HasArtistService, HasUserService, HasTagService,
                      HasIgnoredTagService, HasCountryService, HasLibraryUpdater {
    let artistService: ArtistServiceProtocol
    let userService: UserServiceProtocol
    let tagService: TagServiceProtocol
    let ignoredTagService: IgnoredTagServiceProtocol
    let trackService: TrackServiceProtocol
    let countryService: CountryServiceProtocol

    let libraryUpdater: LibraryUpdaterProtocol

    let onboardingDependencies: OnboardingDependencies

    static var `default`: AppDependency {
        let realmService = RealmService(getRealm: {
            return RealmFactory.realm()
        })
        let networkService = LastFMNetworkService()

        let artistService = ArtistService(
            persistentStore: realmService,
            networkService: networkService
        )
        let userService = UserService(
            persistentStore: realmService,
            networkService: networkService
        )
        let tagService = TagService(
            persistentStore: realmService,
            networkService: networkService
        )
        let ignoredTagService = IgnoredTagService(persistentStore: realmService)
        let trackService = TrackService(
            persistentStore: realmService,
            networkService: networkService
        )
        let countryService = CountryService(persistentStore: realmService)

        let libraryUpdater = LibraryUpdater(
            userService: userService,
            artistService: artistService,
            tagService: tagService,
            ignoredTagService: ignoredTagService,
            trackService: trackService,
            countryService: countryService
        )

        let syncDependencies = SyncDependencies(libraryUpdater: libraryUpdater)

        let onboardingDependencies = OnboardingDependencies(
            artistService: artistService,
            userService: userService,
            ignoredTagService: ignoredTagService,
            syncCoordinatorFactory: { navigationController, popTracker in
                SyncCoordinator(
                    navigationController: navigationController,
                    popTracker: popTracker,
                    dependencies: syncDependencies
                )
            }
        )

        return AppDependency(
            artistService: artistService,
            userService: userService,
            tagService: tagService,
            ignoredTagService: ignoredTagService,
            trackService: trackService,
            countryService: countryService,
            libraryUpdater: libraryUpdater,
            onboardingDependencies: onboardingDependencies
        )
    }
}
