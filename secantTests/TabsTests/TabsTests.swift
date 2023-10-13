//
//  TabsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 10.10.2023.
//

import Combine
import XCTest
import ComposableArchitecture
import Tabs
import Generated
@testable import secant_testnet
@testable import ZcashLightClientKit

class TabsTests: XCTestCase {
    func testHomeBalanceRedirectToTheDetailsTab() {
        let store = TestStore(
            initialState: .placeholder,
            reducer: TabsReducer(tokenName: "TAZ", networkType: .testnet)
        )
        
        store.send(.home(.balanceBreakdown)) { state in
            state.selectedTab = .details
        }
    }
    
    func testSelectionOfTheTab() {
        let store = TestStore(
            initialState: .placeholder,
            reducer: TabsReducer(tokenName: "TAZ", networkType: .testnet)
        )
        
        store.send(.selectedTabChanged(.send)) { state in
            state.selectedTab = .send
        }
    }
    
    func testSettingDestination() {
        let store = TestStore(
            initialState: .placeholder,
            reducer: TabsReducer(tokenName: "TAZ", networkType: .testnet)
        )
        
        store.send(.updateDestination(.settings)) { state in
            state.destination = .settings
        }
    }
    
    func testSettingDestinationDismissal() {
        var placeholderState = TabsReducer.State.placeholder
        placeholderState.destination = .settings
        
        let store = TestStore(
            initialState: placeholderState,
            reducer: TabsReducer(tokenName: "TAZ", networkType: .testnet)
        )
        
        store.send(.updateDestination(nil)) { state in
            state.destination = nil
        }
    }
    
    func testAccountTabTitle() {
        var tabsState = TabsReducer.State.placeholder
        tabsState.selectedTab = .account
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.account,
            "Name of the account tab should be '\(L10n.Tabs.account)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testSendTabTitle() {
        var tabsState = TabsReducer.State.placeholder
        tabsState.selectedTab = .send
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.send,
            "Name of the send tab should be '\(L10n.Tabs.send)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testReceiveTabTitle() {
        var tabsState = TabsReducer.State.placeholder
        tabsState.selectedTab = .receive
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.receive,
            "Name of the receive tab should be '\(L10n.Tabs.receive)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testDetailsTabTitle() {
        var tabsState = TabsReducer.State.placeholder
        tabsState.selectedTab = .details
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.details,
            "Name of the details tab should be '\(L10n.Tabs.details)' but received \(tabsState.selectedTab.title)"
        )
    }
}
