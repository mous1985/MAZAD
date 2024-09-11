// src/global.d.ts
interface Adena {
    AddEstablish(appName: string): Promise<{ code: number }>;
    GetAccount(): Promise<{ data: any }>;
    DoContract(contract: any): Promise<any>;
  }
  
  interface Window {
    adena?: Adena; // Optional chaining in case it's undefined
  }
  