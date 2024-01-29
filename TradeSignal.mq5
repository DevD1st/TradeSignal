#property copyright "Pipscity 2023, Pipscity Institution."
#property link      "https://www.pipscity.org"
#property version   "1.00"

#include <Trade\DealInfo.mqh>

string buy = "BUY";
string sell = "SELL";
string buy_stop = "BUY STOP";
string sell_stop = "SELL STOP";
string buy_limit = "BUY LIMIT";
string sell_limit = "SELL LIMIT";
string fileName = "MQL.txt";
string pendingOrderFileName = "PENDING.txt";
string bigSep = ",";
string smallSep = "_";
ushort u_bigSep;
ushort u_smallSep;
string pendingIsNotFound = "NO";
string pendingIsFound = "YES";

const int UrlDefinedError = 4014; // didn't allow telegram url in terminal

//string discordMsgUrl = "https://discordapp.com/api/webhooks/1143847982672908328/C7ojbPY7wj9cTM2UPdGANkoPCoN7oFbxei_896ps8cY1zQ3-XLMlma1EN8lgDUyBPJQA";
//string telegramUrl = "https://api.telegram.org/bot";

datetime startDate =	"2023.10.01 23:14:42";
datetime stopDate = startDate + (2000 * 24 * 60 * 60);

// mine
string telegramToken = "1848556409:AAHiOy4cSaHw3oxNoB-LIRdwxzdBtNnLceE";
string telegramChatId = "-1001551928963";
string discordSignalUrl = "https://discordapp.com/api/webhooks/1143847982672908328/C7ojbPY7wj9cTM2UPdGANkoPCoN7oFbxei_896ps8cY1zQ3-XLMlma1EN8lgDUyBPJQA";
string discordNotificationUrl = "https://discordapp.com/api/webhooks/1143847982672908328/C7ojbPY7wj9cTM2UPdGANkoPCoN7oFbxei_896ps8cY1zQ3-XLMlma1EN8lgDUyBPJQA";
string telegramToken2 = "1848556409:AAHiOy4cSaHw3oxNoB-LIRdwxzdBtNnLceE";
string telegramChatId2 = "-1001551928963";


// trayon
//string discordSignalUrl = "https://discord.com/api/webhooks/1146841895591477308/ew9pqUXUFX0iisqRh7dOV0lREEB5JoheLSl_XemMupAuJ757hKCB9bvH4iyz6XaFiNeW";
//string discordNotificationUrl = "https://discord.com/api/webhooks/1146845293967593563/Tz9SG-GN_1QHY5-2hQsvP126fSbLiW_J_X7-LD9VbmcT6gssLE3nB7g8hYkQP9paC2MS";
//string telegramToken = "6614107256:AAEKUB9IFJfTG_mU8NYzIxjjQEevCvHC_nY";
//string telegramChatId = "-1001835443518";
//string telegramToken2 = "6614107256:AAEKUB9IFJfTG_mU8NYzIxjjQEevCvHC_nY";
//string telegramChatId2 = "-1002073923690";

// client
//string discordSignalUrl = "https://discord.com/api/webhooks/1153807800942727249/Z0DXNCQpwJ23DuscZvc-V1o5QerSgWYIep__wSBl5zGeiWwElR7sm-DMWWD-ic4R6Eg0";
//string discordNotificationUrl = "https://discord.com/api/webhooks/1153807800942727249/Z0DXNCQpwJ23DuscZvc-V1o5QerSgWYIep__wSBl5zGeiWwElR7sm-DMWWD-ic4R6Eg0";

string telegramUrl = "https://api.telegram.org/bot";


string closedOrderTrack = "CL.txt";
bool isATradeOpened = false;

int OnInit() {
   
   u_bigSep = StringGetCharacter(bigSep, 0);
   u_smallSep = StringGetCharacter(smallSep, 0);
   
   // open order
   bool fileExists = FileIsExist(fileName);
   if (!fileExists)
     {
      // Create the file if it doesn't exist
      int fileHandle = FileOpen(fileName, FILE_WRITE);
      if (fileHandle != INVALID_HANDLE)
        {
         FileClose(fileHandle);
        }
      else
        {
         Print("Error on: ", fileName);
        }
     }
     
     
   // pending order
   bool pendFileExists = FileIsExist(pendingOrderFileName);
   if (!pendFileExists)
     {
      // Create the file if it doesn't exist
      int pendFileHandle = FileOpen(pendingOrderFileName, FILE_WRITE);
      if (pendFileHandle!= INVALID_HANDLE)
        {
         FileClose(pendFileHandle);
        }
      else
        {
         Print("Error on: ", pendingOrderFileName);
        }
     }
     
   EventSetTimer(5);
   return(INIT_SUCCEEDED);
}

void OnTick() {
   int totalOpenTrades = PositionsTotal();
   
   // pending order activated
   for (int i = 0; i < totalOpenTrades; i++) {
      ulong ticket = PositionGetTicket(i);
      PositionSelectByTicket(ticket);      
      string symbol = PositionGetSymbol(i);
      double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      //double tpPrice = PositionGetDouble(POSITION_SL);
      //double slPrice = PositionGetDouble(POSITION_TP);
      double tpPrice = PositionGetDouble(POSITION_TP);
      double slPrice = PositionGetDouble(POSITION_SL);
      double currentBid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double pointValue = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double pips = CalculatePips(positionOpenPrice, currentBid, pointValue, symbol);
      double tpPips = CalculatePips(positionOpenPrice, tpPrice, pointValue, symbol);
      double slPips = CalculatePips(positionOpenPrice, slPrice, pointValue, symbol);
      ENUM_POSITION_TYPE positionType = PositionGetInteger(POSITION_TYPE);
      string percentageProfitLoss = "";
      
      
      string dataArr[];
      StringSplit(pendReadFromFile(), u_bigSep, dataArr);
            
      if (ArraySize(dataArr) > 0) {
         if (ticket) {
         
               for (int i = 0; i < ArraySize(dataArr); i++) {
                  string ticketAndPricesArr[];
                  StringSplit(dataArr[i], u_smallSep, ticketAndPricesArr);
      
                  string pendOrderTicket = ticketAndPricesArr[0];
                  string pendOrderType = ticketAndPricesArr[1];
                  double pendOpenPrice = ticketAndPricesArr[2];
                  double pendTp = ticketAndPricesArr[3];
                  double pendSl = ticketAndPricesArr[4];
                  bool isNotFound = ticketAndPricesArr[5] == pendingIsNotFound;
                  
                  
                  if (ticket == pendOrderTicket) {
                     printf(true);
                     bool fileExists = FileIsExist(pendOrderTicket + ".txt");
                     
                     if (!fileExists) {
                        
                        int pendFileHandle = FileOpen(pendOrderTicket + ".txt", FILE_WRITE);
                        if (pendFileHandle!= INVALID_HANDLE) {
                           FileClose(pendFileHandle);
                        } else {
                           Print("Error on: ", pendOrderTicket + ".txt");
                        }
                              
                        // send message
                        SendTelegramMsg(symbol + " " + pendOrderType + " activated");
                        SendDiscordNotificationMsg(symbol + " " + pendOrderType + " activated");
                        
                     }
                  }
                  
                  
                  
                  if (isNotFound) {
                     if (positionOpenPrice == pendOpenPrice) {
                        
                        if (tpPrice == pendTp || tpPrice == pendSl) {
                        
                           if (slPrice == pendSl || slPrice == pendTp) {
                           
                              // found
                              bool fileExists = FileIsExist(pendOrderTicket + ".txt");
                              if (!fileExists) {
                                 // create file
                                 int pendFileHandle = FileOpen(pendOrderTicket + ".txt", FILE_WRITE);
                                 if (pendFileHandle!= INVALID_HANDLE) {
                                    FileClose(pendFileHandle);
                                 } else {
                                    Print("Error on: ", pendOrderTicket + ".txt");
                                 }
                              
                                 // send message
                                 //SendTelegramMsg(symbol + " " + pendOrderType + " activated");
                                 //SendDiscordNotificationMsg(symbol + " " + pendOrderType + " activated");
                              }
                              
                           }
                     
                        }
                     }
                  }
                }
            
            }
      
         }
   }
   
   
   
   
   
   // notification
   for (int i = 0; i < totalOpenTrades; i++) {
      ulong ticket = PositionGetTicket(i);
      PositionSelectByTicket(ticket);      
      string symbol = PositionGetSymbol(i);
      double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      //double tpPrice = PositionGetDouble(POSITION_SL);
      //double slPrice = PositionGetDouble(POSITION_TP);
      double tpPrice = PositionGetDouble(POSITION_TP);
      double slPrice = PositionGetDouble(POSITION_SL);
      double currentBid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double pointValue = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double pips = CalculatePips(positionOpenPrice, currentBid, pointValue, symbol);
      double tpPips = CalculatePips(positionOpenPrice, tpPrice, pointValue, symbol);
      double slPips = CalculatePips(positionOpenPrice, slPrice, pointValue, symbol);
      ENUM_POSITION_TYPE positionType = PositionGetInteger(POSITION_TYPE);
      string orderType = positionType == POSITION_TYPE_BUY ? buy : sell;
      string percentageProfitLoss = "";
      
      //printf(i + " " + totalOpenTrades);
      
      //if (pips > 0) {
         //printf("OP: " + positionOpenPrice + " TP: " + tpPrice + " SL: " + slPrice + " CB:" + currentBid + " PV: " + 
         //pointValue + " NP: " + (MathFloor(pips/10.0) * 10.0) + " TPP: " + tpPips + " SLP: " + slPips + " PIPS: " + pips
         //+ " P%: " + CalculateProfitLossPercent(tpPips, slPips, pips, true));
      //}
           
      
      // notifications
      if (pips < 10) continue;
      
      int nearestPip = MathFloor(pips/10.0) * 10.0;
      string tickFileName = ticket + ".txt";
      
      //only send notification with profit
      if (positionType == POSITION_TYPE_BUY) {
         if (currentBid > positionOpenPrice) {
            percentageProfitLoss = CalculateProfitLossPercent(tpPips, slPips, pips, true);
         } else { continue; }
      } else if (positionType == POSITION_TYPE_SELL) {
         if (positionOpenPrice > currentBid) {
            percentageProfitLoss = CalculateProfitLossPercent(tpPips, slPips, pips, true);
         } { continue; }
      } else { continue; }
      
      bool fileExists = FileIsExist(tickFileName);
      if (!fileExists)
      {
         // Create the file if it doesn't exist
         int fileHandle = FileOpen(tickFileName, FILE_WRITE);
         if (fileHandle != INVALID_HANDLE)
         {
            FileClose(fileHandle);
            
            writeToTickFuncFile(tickFileName, nearestPip);
            
         }
      } else {
         
         int fileHandleRead = FileOpen(tickFileName, FILE_READ);
         if (fileHandleRead != INVALID_HANDLE)
         {
            string prevPip = FileReadString(fileHandleRead, FileSize(tickFileName));
            FileClose(fileHandleRead);
            
            if (StringToInteger(prevPip) >= nearestPip) continue;
            
            writeToTickFuncFile(tickFileName, nearestPip);
         }
      
      }
      
      SendTelegramMsg(symbol + " " + orderType + " order" + " running " + nearestPip + "pips" + " [" + "%2b" + percentageProfitLoss + "%" + "]");
      SendDiscordNotificationMsg(symbol + " " + orderType + " order" + " running " + nearestPip + "pips" + " [" + percentageProfitLoss + "%" + "]");
   }
}

void writeToTickFuncFile(string tickFileName, int pipsToWrite) {
   int fileHandleWrite = FileOpen(tickFileName, FILE_WRITE);
   if (fileHandleWrite != INVALID_HANDLE)
   {
      FileWriteString(fileHandleWrite, pipsToWrite);
      FileClose(fileHandleWrite);
   }
}

void OnDeinit(const int reason) {
   EventKillTimer();
}

void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {

  //int decimalPlace = Digits();
  double pointValue = SymbolInfoDouble(request.symbol, SYMBOL_POINT);
  string symbol = request.symbol;
  string orderType = getOrderType(request);
  double openPrice = request.price;
  // open order
        if (openPrice == 0) {
            if (orderType == sell || orderType == sell_limit || orderType == sell_stop) {
                  openPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);    
            }
            
            if (orderType == buy || orderType == buy_limit || orderType == buy_stop) {
                  openPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
            }
        }
  
  double takeProfit = request.tp;
  double stopLoss = request.sl;
  string rr = CalculateRRR(openPrice, stopLoss, takeProfit, orderType);
  double pipsTp = CalculatePips(openPrice, takeProfit, pointValue, symbol);
  double pipsSl = CalculatePips(stopLoss, openPrice, pointValue, symbol);
  ulong ticket = result.order;
  
  
      // close
     HistorySelect(0, TimeCurrent());
     long posid=HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);
     
     if (HistorySelectByPosition(posid))
     {
       ulong ticket;
       int dealtot=HistoryDealsTotal();
       ticket=HistoryDealGetTicket(0);
       
       if (ticket>0)
       {
          string sy = HistoryDealGetString(ticket,DEAL_SYMBOL);
          double pointValue = SymbolInfoDouble(sy, SYMBOL_POINT);;
          double prc  = HistoryDealGetDouble(ticket,DEAL_PRICE);
          double closePrice = trans.price;
          double tp = HistoryDealGetDouble(ticket,DEAL_TP);
          double sl = HistoryDealGetDouble(ticket,DEAL_SL);
          double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
          double currentBid = SymbolInfoDouble(sy, SYMBOL_BID);
          double currentAsk = SymbolInfoDouble(sy, SYMBOL_ASK);
          double bidSL = currentBid - sl;
          double bidTP = currentBid - tp;
          double closePips; // recalculate
          if (orderType == buy || orderType == buy_limit || orderType == buy_stop) {
            closePips = CalculatePips(currentAsk, prc, pointValue, sy);
          } else {
            closePips = CalculatePips(currentBid, prc, pointValue, sy);
          }
          
          double tpPips = CalculatePips(prc, tp, pointValue, sy);
          double slPips =  CalculatePips(prc, sl, pointValue, sy);
          
          string percentProfitLoss;
          if (prc != 0 && closePrice != 0) {
          
          
            if (closePrice == tp) {
            
               percentProfitLoss = CalculateProfitLossPercent(tpPips, slPips, tpPips, true);
               string sign = "+";
               
               printf("prc: " + prc);
               printf("Tp: " + tp);
               printf("Sl: " + sl);
               printf("tpPips: " + tpPips);
               printf("slPips: " + slPips);
               printf("percentProfitLoss: " + percentProfitLoss);
               
               string thisOrderType;
               
               if (tp > sl) {
                  thisOrderType = buy;
               } else {
                  thisOrderType = sell;
               }
               
               SendTelegramMsg(sy + " " + thisOrderType + " order" + " hit target " + "[ " + sign + tpPips + " pips" + " ]");
               SendTelegramMsg(sy + " " + thisOrderType + " order" + " trade " + percentProfitLoss + "%" + " profit made");
               
               SendDiscordNotificationMsg(sy + " " + thisOrderType + " order" + " hit target " + "[ " + sign + tpPips + " pips" + " ]");
               SendDiscordNotificationMsg(sy + " " + thisOrderType + " order" + " trade " + percentProfitLoss + "%" + " profit made");
            
               return;
            } else if (closePrice == sl) {
            
               string thisOrderType;
            
               if (tp > sl) {
                  thisOrderType = buy;
               } else {
                  thisOrderType = sell;
               }
            
               percentProfitLoss = CalculateProfitLossPercent(tpPips, slPips, slPips, false);
               string sign = "-";
               
               printf("prc: " + prc);
               printf("Tp: " + tp);
               printf("Sl: " + sl);
               printf("tpPips: " + tpPips);
               printf("slPips: " + slPips);
               printf("percentProfitLoss: " + percentProfitLoss);
               
               SendTelegramMsg(sy + " " + thisOrderType + " order" + " hit stop " + "[ " + sign + slPips + " pips" + " ]");
               SendTelegramMsg(sy + " " + thisOrderType + " order" + " trade " + percentProfitLoss + "%" + " loss incurred");
               
               SendDiscordNotificationMsg(sy + " " + thisOrderType + " order" + " hit stop " + "[ " + sign + slPips + " pips" + " ]");
               SendDiscordNotificationMsg(sy + " " + thisOrderType + " order" + " trade " + percentProfitLoss + "%" + " loss incurred");
            
               return;
            } else { // return 
               // print("UNCALLED");
            }         
            
            }
          
       }
     }
     
   // pending order closed manually  
   if (request.action == TRADE_ACTION_REMOVE) {
       if (result.retcode == TRADE_RETCODE_DONE || result.deal != 0) {
         SendTelegramMsg(symbol + " " + orderType + " pending order deleted");
         SendDiscordNotificationMsg(symbol + " " + orderType + " pending order deleted");
         return;
       }
   }
   
      
   
  
  // order opened, pending order, close manually
  if (request.action == TRADE_ACTION_DEAL || request.action == TRADE_ACTION_PENDING) {
      if (result.retcode == TRADE_RETCODE_DONE || result.deal != 0) {
            // manual closure of buy/sell
         if ((orderType == buy || orderType == sell) && request.position != 0) {
            string dataArr[];
            StringSplit(readFromFile(), u_bigSep, dataArr);
            
            if (ArraySize(dataArr) < 1) return;
            
            for (int i = 0; i < ArraySize(dataArr); i++) {
               string ticketAndPricesArr[];
               StringSplit(dataArr[i], u_smallSep, ticketAndPricesArr);
               
               if (StringToInteger(ticketAndPricesArr[0]) == request.position) {
                  double manualClosePips = CalculatePips(ticketAndPricesArr[1], openPrice, pointValue, symbol);
                  
                  string sign = "+";
                  double takeP = StringToDouble(ticketAndPricesArr[2]);
                  double stopL = StringToDouble(ticketAndPricesArr[3]);
                  
                  double tpPips = CalculatePips(ticketAndPricesArr[1], takeP, pointValue, symbol);
                  double slPips =  CalculatePips(stopL, ticketAndPricesArr[1], pointValue, symbol);
                  
                  // double percentProfitLoss = CalculatePercentProfitLoss();
                  string percentProfitLoss = "";
                  
                  // the orderType is inversed for manual closure so this is actually buy
                  if (orderType == sell) {
                     if (openPrice > StringToDouble(ticketAndPricesArr[1])) {
                        sign = "+";
                        percentProfitLoss = CalculateProfitLossPercent(tpPips, slPips, manualClosePips, true);
                        
                        SendTelegramMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed manually " + "[ " + sign + manualClosePips + " pips" + " ]");
                        SendTelegramMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed with " + percentProfitLoss + "%" + " [ PROFIT ]");
                        
                        SendDiscordNotificationMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed manually " + "[ " + sign + manualClosePips + " pips" + " ]");
                        SendDiscordNotificationMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed with " + percentProfitLoss + "%" + " [ PROFIT ]");
                     } else {
                        sign = "-";
                        percentProfitLoss = CalculateProfitLossPercent(tpPips, slPips, manualClosePips, false);
                        
                        SendTelegramMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed manually " + "[ " + sign + manualClosePips + " pips" + " ]");
                        SendTelegramMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed with " + percentProfitLoss + "%" + " [ LOSS ]");
                        
                        SendDiscordNotificationMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed manually " + "[ " + sign + manualClosePips + " pips" + " ]");
                        SendDiscordNotificationMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed with " + percentProfitLoss + "%" + " [ LOSS ]");
                     }
                  } else {
                     if (StringToDouble(ticketAndPricesArr[1]) > openPrice) {
                        sign = "+";
                        percentProfitLoss = CalculateProfitLossPercent(tpPips, slPips, manualClosePips, true);
                        
                        SendTelegramMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed manually " + "[ " + sign + manualClosePips + " pips" + " ]");
                        SendTelegramMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed with " + percentProfitLoss + "%" + " [ PROFIT ]");
                        
                        SendDiscordNotificationMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed manually " + "[ " + sign + manualClosePips + " pips" + " ]");
                        SendDiscordNotificationMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed with " + percentProfitLoss + "%" + " [ PROFIT ]");
                     } else {
                        sign = "-";
                        percentProfitLoss = CalculateProfitLossPercent(tpPips, slPips, manualClosePips, false);
                        
                        SendTelegramMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed manually " + "[ " + sign + manualClosePips + " pips" + " ]");
                        SendTelegramMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed with " + percentProfitLoss + "%" + " [ LOSS ]");
                        
                        SendDiscordNotificationMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed manually " + "[ " + sign + manualClosePips + " pips" + " ]");
                        SendDiscordNotificationMsg(symbol + " " + getInverseOrderType(orderType) + " order" + " closed with " + percentProfitLoss + "%" + " [ LOSS ]");
                     }
                  }
                  
                  
                  return;
               }
            }
            
         }
          
        
        isATradeOpened = true;
        writeToFile(ticket, openPrice, takeProfit, stopLoss);
        
        if (orderType == buy_limit || orderType == buy_stop || orderType == sell_limit || orderType == sell_stop) {
            writePendingOrderToFile(ticket, orderType, openPrice, takeProfit, stopLoss, pendingIsNotFound);
            //printf("PEND: " + ticket);
         }
         
         string messageStr = "Trade Calls\n\n" + "Pair: " + symbol + "\n" + "Type: " + orderType + "\n\n" +
                              "Entry Price: " + ConvertToDecimalPlaces(openPrice, pointValue) + "\n" + 
                              "Stop Loss Price: " + ConvertToDecimalPlaces(stopLoss, pointValue) + " [" + pipsSl + "pips" + "]" +
                              "\n" + "Take Profit Price: " + ConvertToDecimalPlaces(takeProfit, pointValue) 
                              + " [" + pipsTp + "pips" + "]" + "\n" + "RR: " + rr;
                              
        if (orderType == buy || orderType == buy_limit || orderType == buy_stop) {
            SendTelegramMsgWithImage(telegramUrl, telegramToken, telegramChatId, messageStr, "BUY.jpg");
        } else {
            SendTelegramMsgWithImage(telegramUrl, telegramToken, telegramChatId, messageStr, "SELL.jpg");
        }
         
         SendDiscordSignalMsg("Trade Calls");
         SendDiscordSignalMsg("Pair: " + symbol);
         SendDiscordSignalMsg("Type: " + orderType);
         SendDiscordSignalMsg("Entry Price: " + ConvertToDecimalPlaces(openPrice, pointValue));
         SendDiscordSignalMsg("Stop Loss Price: " + ConvertToDecimalPlaces(stopLoss, pointValue) + " [" + pipsSl + "pips" + "]");
         SendDiscordSignalMsg("Take Profit Price: " + ConvertToDecimalPlaces(takeProfit, pointValue) + " [" + pipsTp + "pips" + "]");
         SendDiscordSignalMsg("RR: " + rr);
         
         return;
      }
  }
        
}

string getInverseOrderType(string orderType) {
   if (orderType == buy) {
      return sell;
   }
   if (orderType == sell) {
      return buy;
   }
   
   return orderType;
}

// Calculate Risk-Reward Ratio
string CalculateRRR(double entryPrice, double stopLossPrice, double takeProfitPrice, string orderType) {
    if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return "";
   }
    
    double risk; 
    double reward;
    
    if (orderType == buy || orderType == buy_limit || orderType == buy_stop) {
      risk = entryPrice - stopLossPrice;
      reward = takeProfitPrice - entryPrice;
    } else if(orderType == sell || orderType == sell_limit || orderType == sell_stop) {
      risk = stopLossPrice - entryPrice;
      reward = entryPrice - takeProfitPrice;
    } else {
      return "0"; // order type not in consideration
    }

    if (risk == 0.0) {
        // Print("Warning: Risk is zero, potential division by zero.");
        return "Infinity"; // if the risk is zero (or very close to zero), the RRR will be infinite
    }
    
    // example: risk 20, reward 100, 1:5
    string rrr = "1" + ":" + DoubleToString(MathAbs(reward/risk), 3);
    // string rrr = "1" + ":" + IntegerToString(MathAbs(MathRound(reward/risk)));
    return rrr;
}

double CalculatePips(double entryPrice, double exitPrice, double pointValue, string currencyPair) {

   printf(currencyPair);

   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return 0;
   }
   
   int dividedBy = 10;
   
   // if (currencyPair == "XAUUSD") dividedBy = 100;
   
   double pips = (exitPrice - entryPrice) / (pointValue * dividedBy);
   double normPip = NormalizeDouble(MathAbs(pips), 2);
   return normPip;
   //return DoubleToString(MathAbs(pips), 2);
}

string CalculateProfitLossPercent(double tpPips, double slPips, double currPips, bool isCurrPipsProfit) {
 if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return "";
   }
 
 string signedPips = "+0";
 
 if (isCurrPipsProfit) {
   signedPips = "+" + DoubleToString(currPips/slPips, 3);
   
 } else {
    //signedPips = "-" + (currPips/tpPips);
   
   signedPips = "-" + DoubleToString(currPips/slPips, 3);
 }
 return signedPips;
}

string getOrderType(const MqlTradeRequest& request) {
   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return "";
   }
   
   string orderType = "UNKNOWN";
   if (request.type == ORDER_TYPE_BUY) {
      orderType = buy;
   } else if (request.type == ORDER_TYPE_SELL) {
      orderType = sell;
   } else if (request.type == ORDER_TYPE_BUY_LIMIT) {
      orderType = buy_limit;
   } else if (request.type == ORDER_TYPE_SELL_LIMIT) {
      orderType = sell_limit;
   } else if (request.type == ORDER_TYPE_BUY_STOP) {
      orderType = buy_stop;
   } else if (request.type == ORDER_TYPE_SELL_STOP) {
      orderType = sell_stop;
   }
   
   return orderType;
}

void SendDiscordNotificationMsg(string message) {
   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return;
   }
   
   
   ResetLastError();
   
   string headers = "Content-Type: application/json\r\n";
   // string strJsonText = "{\r\n\"content\": \"value\"\r\n}";
   string strJsonText = "{\r\n\"content\": " + "\"" + message + "\"" + "\r\n}";
   uchar jsonData[];
   StringToCharArray(strJsonText,jsonData,0,StringLen(strJsonText),CP_UTF8);
   
   char serverResult[];
   string serverHeaders;   
   string requestHeaders = "Content-Type: application/json; charset=utf-8\r\nExpect: 100-continue\r\nConnection: Keep-Alive";

   int res = WebRequest("POST", discordNotificationUrl, headers, 5000, jsonData, serverResult, serverHeaders);
   
   if (res == -1) {
      printf("Error sending discord message");
      printf(res);
   }
   
   ResetLastError();
}

void SendDiscordSignalMsg(string message) {
   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return;
   }
   
   
   ResetLastError();
   
   string headers = "Content-Type: application/json\r\n";
   // string strJsonText = "{\r\n\"content\": \"value\"\r\n}";
   string strJsonText = "{\r\n\"content\": " + "\"" + message + "\"" + "\r\n}";
   uchar jsonData[];
   StringToCharArray(strJsonText,jsonData,0,StringLen(strJsonText),CP_UTF8);
   
   char serverResult[];
   string serverHeaders;   
   string requestHeaders = "Content-Type: application/json; charset=utf-8\r\nExpect: 100-continue\r\nConnection: Keep-Alive";

   int res = WebRequest("POST", discordSignalUrl, headers, 5000, jsonData, serverResult, serverHeaders);
   
   if (res == -1) {
      printf("Error sending discord message");
      printf(res);
   }
   
   ResetLastError();
}

void SendTelegramMsg(string message) {
    if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return;
   }
    
    
    ResetLastError();
    
    string url = telegramUrl + telegramToken + "/sendMessage?chat_id=" + telegramChatId + "&text=" + message;
    // Define variables for storing the result of the web request
    string result;
    string cookie=NULL;
    char post[],resultt[];

    // Send a GET request to the Telegram API using the constructed URL and store the result in the 'result' variable
    int res = WebRequest("GET",url,cookie,NULL,10000,post,10000,resultt,result);
    
    if (res == -1) {
      printf("Error sending telegram message");
      printf(res);
   }
    
    ResetLastError();
    
    // second signal
    //string url2 = telegramUrl + telegramToken2 + "/sendMessage?chat_id=" + telegramChatId2 + "&text=" + message;
    // Define variables for storing the result of the web request
    //string result2;
    //string cookie2=NULL;
    //char post2[],resultt2[];

    // Send a GET request to the Telegram API using the constructed URL and store the result in the 'result' variable
    //int res2 = WebRequest("GET",url2,cookie2,NULL,10000,post2,10000,resultt2,result2);
    
    //if (res2 == -1) {
    //  printf("Error sending second telegram message");
    //  printf(res2);
   //}
    
    //ResetLastError();
}

bool SendTelegramMsgWithImage(string url, string token, string chat, string text, string fileName = "") {
   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return false;
   }
     
   ResetLastError();
   
    
   string headers = "";
   string requestUrl = "";
   char postData[];
   char resultData[];
   string resultHeaders;
   int timeout = 5000;
   
   requestUrl = StringFormat("%s%s/sendPhoto", url, token);
   
   if (!GetPostData(postData, headers, chat, text, fileName)) {
      return false;
   }
   
   int response = WebRequest("POST", requestUrl, headers, timeout, postData, resultData, resultHeaders);
   
   if (response == -1) {
      printf("Error sending second telegram message");
      printf(response);
   }
   
   ResetLastError();
   return response == 200;
}

bool GetPostData(char &postData[], string &headers, string chat, string text, string fileName) {
   ResetLastError();
   
   if (!FileIsExist(fileName)) {
      Print(fileName + " does not exist");
      return false;
   }
   
   int flags = FILE_READ | FILE_BIN;
   int file = FileOpen(fileName, flags);
   if (file == INVALID_HANDLE) {
      int err = GetLastError();
      PrintFormat("Could not open file '%s', error=%i", fileName, err);
      return false;
   }
   
   int fileSize = (int) FileSize(file);
   uchar photo[];
   ArrayResize(photo, fileSize);
   FileReadArray(file, photo, 0, fileSize);
   FileClose(file);
   
   string hash = "";
   AddPostData(postData, hash, "chat_id", chat);
   if (StringLen(text) > 0) {
      AddPostData(postData, hash, "caption", text);   
   }
   AddPostData(postData, hash, "photo", photo, fileName);
   ArrayCopy(postData, "--" + hash + "--\r\n");
   
   headers = "Content-Type: multipart/form-data; boundary=" + hash + "\r\n";
   
   return true;
}

void AddPostData(uchar &data[], string &hash, string key = "", string value = "") {
   uchar valueArr[];
   StringToCharArray(value, valueArr, 0, StringLen(value));
   
   AddPostData(data, hash, key, valueArr);
   return;
}

void AddPostData(uchar &data[], string &hash, string key, uchar &value[], string fileName = "") {
   if (hash == "") {
      hash = Hash();
   }
   
   ArrayCopy(data, "\r\n");
   ArrayCopy(data, "--" + hash + "\r\n");
   if (fileName == "") {
      ArrayCopy(data, "Content-Disposition: form-data; name=\"" + key + "\"\r\n");
   } else {
      ArrayCopy(data, "Content-Disposition: form-data; name=\"" + key + "\"; filename=\"" + fileName + "\"\r\n");
   }
   ArrayCopy(data, "\r\n");
   ArrayCopy(data, value, ArraySize(data));
   ArrayCopy(data, "\r\n");
   
   return;
}

void ArrayCopy(uchar &dst[], string src) {
   uchar srcArray[];
   StringToCharArray(src, srcArray, 0, StringLen(src));
   ArrayCopy(dst, srcArray, ArraySize(dst), 0, ArraySize(srcArray));
   return;
}

string Hash() {
   uchar tmp[];
   string seed = IntegerToString(TimeCurrent());
   int len = StringToCharArray(seed, tmp, 0, StringLen(seed));
   string hash = "";
   for (int i = 0; i < len; i++)
      hash += StringFormat("%02X", tmp[i]);
   hash = StringSubstr(hash, 0, 16);
   
   return hash;
}

void writePendingOrderToFile(ulong ticket, string orderType, double openPrice, double takeProfit,
                             double stopLoss, string pendingFound) {
   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return;
   }
   
   string currContent = ticket + smallSep + orderType + smallSep + openPrice + smallSep + takeProfit
    + smallSep + stopLoss + smallSep + pendingFound;
   
   string newContents = pendReadFromFile();
   if (newContents == "") {
      newContents = currContent;
   } else {
      newContents = newContents + bigSep + currContent;
   }
   
   int fileHandleWrite = FileOpen(pendingOrderFileName, FILE_WRITE);
   if (fileHandleWrite != INVALID_HANDLE)
     {
      FileWriteString(fileHandleWrite, newContents);
      FileClose(fileHandleWrite);
     }
   else
     {
      Print("Failed to open file for writing: ", pendingOrderFileName);
     }
}

void writeToFile(ulong ticket, double price, double tp, double sl) {
   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return;
   }
   
   string newContents = readFromFile();
   if (newContents == "") {
      newContents = ticket + smallSep + price + smallSep + tp + smallSep + sl;
   } else {
      newContents = newContents + bigSep + ticket + smallSep + price + smallSep + tp + smallSep + sl;
   }
   
   int fileHandleWrite = FileOpen(fileName, FILE_WRITE);
   if (fileHandleWrite != INVALID_HANDLE)
     {
      FileWriteString(fileHandleWrite, newContents);
      FileClose(fileHandleWrite);
     }
   else
     {
      Print("Failed to open file for writing: ", fileName);
     }
}

string readFromFile() {
   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return "";
   }
   
   string fileContents;
   int fileHandleRead = FileOpen(fileName, FILE_READ);
   if (fileHandleRead != INVALID_HANDLE)
     {
      string contents = FileReadString(fileHandleRead, FileSize(fileName));
      FileClose(fileHandleRead);
      return contents;
     }
   else
     {
      Print("Failed to open file for reading: ", fileName);
      return "";
     }
}

string pendReadFromFile() {
   if (IsExpertExpired()) {
      Alert("Expert has Expired");
      return "";
   }
   
   string fileContents;
   int fileHandleRead = FileOpen(pendingOrderFileName, FILE_READ);
   if (fileHandleRead != INVALID_HANDLE)
     {
      string contents = FileReadString(fileHandleRead, FileSize(pendingOrderFileName));
      FileClose(fileHandleRead);
      return contents;
     }
   else
     {
      Print("Failed to open file for reading: ", pendingOrderFileName);
      return "";
     }
}

string ConvertToDecimalPlaces(double num, double pointValue) {
   int digit = GetDigitAfterDecimalPlace(pointValue);
   return DoubleToString(num, digit);
}

int GetDigitAfterDecimalPlace(double pointValue) {
   int precision = StringLen(pointValue) - StringFind(pointValue, ".") - 1;
   
   return precision;
}

bool IsExpertExpired() {
    return TimeCurrent() > stopDate;
}