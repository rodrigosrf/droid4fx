datetime vHoraOrdem = 0;

void EST_CONTRA_MEDIA(
                     double pLote, 
                     int pPeriodo, 
                     int pNumMagico, 
                     int pHoraIni, 
                     int pHoraFim)
{

   bool   vHoraValida = false;
   double vMedia01 = 0;
   double vMedia00 = 0;  
   int    vTicket  = 0;    
  
   vHoraValida = ((pHoraIni==0 && pHoraFim==0) ||
                  (Hour()>=pHoraIni && Hour()<=pHoraFim));

   if(Time[1]!=vHoraOrdem)
   {
      vMedia01 = iMA(_Symbol, 0, pPeriodo, 0, MODE_EMA, PRICE_CLOSE, 1);
   
      if(Close[1]>vMedia01)
      {
         vTicket = OrderSend(
                     _Symbol, 
                     OP_SELL, 
                     pLote, 
                     Bid, 
                     3, 0, 0, "", pNumMagico, 0, Blue);   
      }
      else if(Close[1]<vMedia01)
      {
         vTicket = OrderSend(
                     _Symbol, 
                     OP_BUY, 
                     pLote, 
                     Ask, 
                     3, 0, 0, "", pNumMagico, 0, Blue);   
      }
   }
   else
   {
      vMedia00 = iMA(_Symbol, 0, pPeriodo, 0, MODE_EMA, PRICE_CLOSE, 0);
   
      if(High[0]>=vMedia00)
      {
         FecharOperacoes(OP_BUY, pNumMagico);
      }
      else if(Low[0]<=vMedia00)
      {
         FecharOperacoes(OP_SELL, pNumMagico);
      }
   }               
                  
}
