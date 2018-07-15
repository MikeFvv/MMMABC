/**
 * Created by Mike on 2017/11/27.
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
    Platform,
    StyleSheet,
    Modal,
    Text,
    View,
    NetInfo,
    ProgressViewIOS
} from 'react-native';

import CodePush from "react-native-code-push"
import * as Progress from 'react-native-progress';

// import FPApp from './js/FPApp'


const instructions = Platform.select({
    ios: 'Press Cmd+R to reload,\n' +
        'Cmd+D or shake for dev menu',
    android: 'Double tap R on your keyboard to reload,\n' +
        'Shake or press menu button for dev menu',
});

export default class App extends Component<{}> {

    constructor(props) {
        super(props)
        // ✰✰✰✰✰✰ 这句代码一定要添加到这里 不可删除 ✰✰✰✰✰✰
        this.codePushInit();
        // ✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰

    }








    componentWillUnmount() {


        // ✰✰✰✰✰✰✰✰✰ 请勿删除 ✰✰✰✰✰✰✰
        //移除监听
        NetInfo.isConnected.removeEventListener('connectionChange', this._handleIsConnectedChange);
        // ✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰
    }



    render() {
        return (
            <View style={styles.container}>

                {/* *** 可删除 ***/}
                {/* <Text style={styles.welcome}>
                    Welcome to React Native!
                 </Text>
                <Text style={styles.instructions}>
                    To get started, edit App.js
                 </Text>
                <Text style={styles.instructions}>
                    {instructions}
                </Text> */}


                {/* *** 马甲页面 示例 自己添加更改,只作为简单参考，可删除 ***/}
                {/* <FPApp /> */}




                {/* ✰✰✰✰✰ 热更新视图 不可删除 ✰✰✰✰✰*/}
                {this._modalView()}
                {/* ✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰ */}

            </View>
        );
    }






    // ✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰
    // 热更新代码勿更改  ✰✰✰✰✰✰✰✰✰ 🐶🐶🐶 ✰✰✰✰✰✰✰✰✰
    codePushInit() {
        this.checkUpdate = this.checkUpdate.bind(this)
        this.state = {
            isShowUpdate: false,
            syncMessage: '正在检测更新',
            mmprogress: 0,
            indeterminate: true,
        }
        global.GlobalRNmmStatus = this.props['mmStatus'];

        if (global.GlobalRNmmStatus == 1 || global.GlobalRNmmStatus >= 5) {
            this.checkUpdate()
        }
        NetInfo.isConnected.addEventListener('connectionChange', this._handleIsConnectedChange);
    }

    codePushStatusDidChange(syncStatus) {
        switch (syncStatus) {
            case CodePush.SyncStatus.CHECKING_FOR_UPDATE:
                this.setState({
                    syncMessage: '正在检查新配置'
                })
                break
            case CodePush.SyncStatus.DOWNLOADING_PACKAGE:
                if (!this.state.isShowUpdate) {
                    this.setState({
                        isShowUpdate: true
                    })
                }
                break
            case CodePush.SyncStatus.INSTALLING_UPDATE:
                break
            case CodePush.SyncStatus.UP_TO_DATE:
                this.setState({
                    syncMessage: '正在加载配置'
                })
                break
            case CodePush.SyncStatus.UPDATE_INSTALLED:
                this.setState({
                    syncMessage: '应用更新完成,重启中...'
                })
                break
            case CodePush.SyncStatus.UNKNOWN_ERROR:
                this.setState({
                    syncMessage: "应用更新出错,请退出重新启动!"
                });
                break;
        }
    }

    codePushDownloadDidProgress(progress) {
        this.setState({
            syncMessage: `正在下载新配置${(progress.receivedBytes / progress.totalBytes * 100).toFixed(2)}%`,
            mmprogress: Number(progress.receivedBytes / progress.totalBytes),
            indeterminate: false,
        })
    }

    checkUpdate() {
        CodePush.checkForUpdate().then((update) => {
            console.log('update', update)
            if (!update) {
                this.setState({ syncMessage: '当前是最新配置' })
            } else {
                CodePush.sync(
                    { installMode: CodePush.InstallMode.IMMEDIATE },
                    this.codePushStatusDidChange.bind(this),
                    this.codePushDownloadDidProgress.bind(this)
                ).catch((e) => {
                    console.log(e)
                })
            }
        }).catch((err) => {
            console.log(err)
        })
        CodePush.notifyAppReady()
    }

    codePushView() {
        return (
            <View style={styles.codepushContainer}>
                <Text style={styles.codepushWelcome}>
                    欢迎您,请等待更新完成
                 </Text>
                <Text style={styles.codePushText}>
                    {this.state.syncMessage}
                </Text>
                <Progress.Bar
                    style={styles.progressStyle}
                    progress={this.state.mmprogress}
                    indeterminate={this.state.indeterminate}
                />
            </View>
        );
    }

    _handleIsConnectedChange = (isConnected) => {
        if (isConnected) {
            if (global.GlobalRNmmStatus == 1 || global.GlobalRNmmStatus >= 5) {
                this.checkUpdate()
            }
        }
    }

    _modalView() {
        return (
            <Modal
                visible={this.state.isShowUpdate}
                animationType={'none'}
                transparent={true}
                onRequestClose={() => this._onHotUpdateClose()}
            >{this._isShowHotUpdateView()}</Modal>
        );
    }

    _isShowHotUpdateView() {
        return (
            <View style={styles.codepushContainer}>
                <Text style={styles.codepushWelcome}>
                    欢迎您,请等待更新完成
               </Text>
                <Text style={styles.codePushText}>
                    {this.state.syncMessage}
                </Text>
                <Progress.Bar
                    style={styles.progressStyle}
                    progress={this.state.mmprogress}
                    indeterminate={this.state.indeterminate}
                />
                {/* <ProgressViewIOS style={styles.progressView} progressTintColor='red' progressViewStyle='bar' progress={this.state.mmprogress} /> */}
            </View>
        )
    }
    _onHotUpdateClose() {

    }
    // ✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰


}



const styles = StyleSheet.create({

    container: {
        flex: 1,
    },
    // welcome: {
    //     fontSize: 20,
    //     textAlign: 'center',
    //     margin: 10,
    // },



    // ********************************


    // 请勿删除 ✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰
    codepushContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    codepushWelcome: {
        fontSize: 18,
        textAlign: 'center',
        margin: 10,
    },
    codePushText: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
    progressStyle: {
        margin: 5,
    },
    // ✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰✰

});
