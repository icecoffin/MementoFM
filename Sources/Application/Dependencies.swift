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
import TransientModels

import SharedServicesInterface
import SharedServices

import Onboarding
import Sync
import IgnoredTagsInterface
import IgnoredTags
import EnterUsername
import Settings

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
    let settingsDependencies: SettingsDependencies

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

        let ignoredTagsDependencies = IgnoredTagsDependencies(ignoredTagService: ignoredTagService, artistService: artistService)
        let ignoredTagsCoordinatorFactory = IgnoredTagsCoordinatorFactory(dependencies: ignoredTagsDependencies)

        let syncDependencies = SyncDependencies(libraryUpdater: libraryUpdater)
        let syncCoordinatorFactory = SyncCoordinatorFactory(dependencies: syncDependencies)

        let enterUsernameDependencies = EnterUsernameDependencies(userService: userService)
        let enterUsernameCoordinatorFactory = EnterUsernameCoordinatorFactory(dependencies: enterUsernameDependencies)

        let onboardingDependencies = OnboardingDependencies(
            artistService: artistService,
            userService: userService,
            ignoredTagService: ignoredTagService,
            syncCoordinatorFactory: syncCoordinatorFactory,
            ignoredTagsCoordinatorFactory: ignoredTagsCoordinatorFactory,
            enterUsernameCoordinatorFactory: enterUsernameCoordinatorFactory
        )

        let settingsDependencies = SettingsDependencies(
            syncCoordinatorFactory: syncCoordinatorFactory,
            ignoredTagsCoordinatorFactory: ignoredTagsCoordinatorFactory,
            enterUsernameCoordinatorFactory: enterUsernameCoordinatorFactory
        )

        return AppDependency(
            artistService: artistService,
            userService: userService,
            tagService: tagService,
            ignoredTagService: ignoredTagService,
            trackService: trackService,
            countryService: countryService,
            libraryUpdater: libraryUpdater,
            onboardingDependencies: onboardingDependencies,
            settingsDependencies: settingsDependencies
        )
    }
}
