// import {
//     EAdenaResponseStatus,
//     EAdenaResponseType,
//     IAccountInfo,
//     IAdenaMessage,
//     IAdenaResponse
//   } from './adena.types';
//   import { BroadcastTxCommitResult } from '@gnolang/tm2-js-client';
  
//   export class AdenaService {
//     static validateAdena() {
//       // @ts-expect-error This should be injected by the extension
//       const adena = window.adena;
  
//       if (!adena) {
//         window.open('https://adena.app/', '_blank');
//         throw new Error('Adena not installed');
//       }
//     }
  
//     static async establishConnection(name: string): Promise<void> {
//       AdenaService.validateAdena();
      

  
//       // @ts-expect-error This should be injected by the extension
//       const adena = window.adena;
  
//       const response: IAdenaResponse = await adena.AddEstablish(name);
  
//       if (
//         response.status === EAdenaResponseStatus.SUCCESS ||
//         response.type === EAdenaResponseType.ALREADY_CONNECTED
//       ) {
//         return;
//       }
  
//       throw new Error('unable to establish connection');
//     }
  
//     static async getAccountInfo(): Promise<IAccountInfo> {
//       AdenaService.validateAdena();
  
//       // @ts-expect-error This should be injected by the extension
//       const adena = window.adena;
  
//       const response: IAdenaResponse = await adena.GetAccount();
//       if (response.status !== EAdenaResponseStatus.SUCCESS) {
//         throw new Error('unable to fetch account info');
//       }
  
//       return response.data as IAccountInfo;
//     }
  
//     static async switchNetwork(chainID: string): Promise<void> {
//       AdenaService.validateAdena();
  
//       // @ts-expect-error This should be injected by the extension
//       const adena = window.adena;
  
//       const response: IAdenaResponse = await adena.SwitchNetwork(chainID);
//       if (
//         response.status === EAdenaResponseStatus.SUCCESS ||
//         response.type === EAdenaResponseType.REDUNDANT_CHANGE_REQUESTED
//       ) {
//         return;
//       }
  
//       throw new Error('unable to switch Adena network');
//     }
  
//     static async sendTransaction(
//       messages: IAdenaMessage[],
//       gasWanted: number
//     ): Promise<BroadcastTxCommitResult> {
//       AdenaService.validateAdena();
  
//       // @ts-expect-error This should be injected by the extension
//       const adena = window.adena;
  
//       const response: IAdenaResponse = await adena.DoContract({
//         messages: messages,
//         gasFee: 1000000, // 1 gnot
//         gasWanted: gasWanted // ugnot
//       });
  
//       if (response.status !== EAdenaResponseStatus.SUCCESS) {
//         throw new Error(`unable to send transaction: ${response.message}`);
//       }
  
//       return response.data as BroadcastTxCommitResult;
//     }
//   }
  
// frontend/utils/adena.ts

import {
    EAdenaResponseStatus,
    EAdenaResponseType,
    IAccountInfo,
    IAdenaMessage,
    IAdenaResponse,
    BroadcastTxCommitResult
  } from './adena.types';
  import { MsgAddPackage, MsgCall, MsgSend, MsgRun } from '@gnolang/gno-js-client';
  
  declare global {
    interface Window {
      adena: any;
    }
  }
  
  export class AdenaService {
    // Vérifie si Adena Wallet est installé
    static validateAdena() {
      const adena = window.adena;
  
      if (!adena) {
        window.open('https://adena.app/', '_blank');
        throw new Error('Adena Wallet n\'est pas installé');
      }
    }
  
    // Établit la connexion avec Adena Wallet
    static async establishConnection(name: string): Promise<void> {
      this.validateAdena();
  
      const adena = window.adena;
  
      const response: IAdenaResponse = await adena.AddEstablish(name);
  
      if (
        response.status === EAdenaResponseStatus.SUCCESS ||
        response.type === EAdenaResponseType.ALREADY_CONNECTED
      ) {
        return;
      }
  
      throw new Error('Impossible d\'établir une connexion avec Adena Wallet');
    }
  
    // Récupère les informations du compte
    static async getAccountInfo(): Promise<IAccountInfo> {
      this.validateAdena();
  
      const adena = window.adena;
  
      const response: IAdenaResponse = await adena.GetAccount();
      if (response.status !== EAdenaResponseStatus.SUCCESS) {
        throw new Error('Impossible de récupérer les informations du compte');
      }
  
      return response.data as IAccountInfo;
    }
  
    // Change le réseau dans Adena Wallet
    static async switchNetwork(chainID: string): Promise<void> {
      this.validateAdena();
  
      const adena = window.adena;
  
      const response: IAdenaResponse = await adena.SwitchNetwork(chainID);
      if (
        response.status === EAdenaResponseStatus.SUCCESS ||
        response.type === EAdenaResponseType.REDUNDANT_CHANGE_REQUESTED
      ) {
        return;
      }
  
      throw new Error('Impossible de changer le réseau Adena');
    }
  
    // Envoie une transaction signée via Adena Wallet
    static async sendTransaction(
      messages: IAdenaMessage[],
      gasWanted: number
    ): Promise<BroadcastTxCommitResult> {
      this.validateAdena();
  
      const adena = window.adena;
  
      const response: IAdenaResponse = await adena.DoContract({
        messages: messages,
        gasFee: 1000000, // 1 gnot
        gasWanted: gasWanted // ugnot
      });
  
      if (response.status !== EAdenaResponseStatus.SUCCESS) {
        throw new Error(`Impossible d'envoyer la transaction : ${response.message}`);
      }
  
      return response.data as BroadcastTxCommitResult;
    }
  }
  