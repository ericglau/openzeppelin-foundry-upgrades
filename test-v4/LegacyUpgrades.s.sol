// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

import {Greeter} from "./contracts/Greeter.sol";
import {GreeterProxiable} from "./contracts/GreeterProxiable.sol";
import {GreeterV2} from "./contracts/GreeterV2.sol";
import {GreeterV2Proxiable} from "./contracts/GreeterV2Proxiable.sol";

import {LegacyUpgrades} from "openzeppelin-foundry-upgrades/LegacyUpgrades.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

/**
 * @dev Sample script to deploy and upgrade contracts using transparent, UUPS, and beacon proxies.
 */
contract UpgradesScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // TODO add validation steps throughout

        // example deployment and upgrade of a transparent proxy
        address proxyAdmin = address(new ProxyAdmin());
        address transparentProxy = address(new TransparentUpgradeableProxy(address(new Greeter()), proxyAdmin, abi.encodeCall(Greeter.initialize, ("hello"))));
        LegacyUpgrades.upgradeProxy(transparentProxy, "GreeterV2.sol", abi.encodeCall(GreeterV2.resetGreeting, ()));

        // // example deployment and upgrade of a UUPS proxy
        // address uupsProxy = Upgrades.deployUUPSProxy(
        //     "GreeterProxiable.sol",
        //     abi.encodeCall(GreeterProxiable.initialize, (msg.sender, "hello"))
        // );
        // Upgrades.upgradeProxy(
        //     uupsProxy,
        //     "GreeterV2Proxiable.sol",
        //     abi.encodeCall(GreeterV2Proxiable.resetGreeting, ())
        // );

        // example deployment of a beacon proxy and upgrade of the beacon
        // address beacon = Upgrades.deployBeacon("Greeter.sol", msg.sender);
        // Upgrades.deployBeaconProxy(beacon, abi.encodeCall(Greeter.initialize, (msg.sender, "hello")));
        address impl = address(new Greeter());
        address beacon = address(new UpgradeableBeacon(impl));
        new BeaconProxy(beacon, abi.encodeCall(Greeter.initialize, ("hello")));
        LegacyUpgrades.upgradeBeacon(beacon, "GreeterV2.sol");

        vm.stopBroadcast();
    }
}
