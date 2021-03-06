void EST_GRID_START(
                     double pLote, 
                     int pGrid, 
                     int pNumMagico, 
                     int pHoraIni, 
                     int pHoraFim)
{

   double vProjecao = (pGrid * (Point * 10));
   int    vTipo = -1;
   int    vTicket = 0;
   double vLote = 0;
   double vPrecoAbertura = 0;
   double vDiferenca = 0;
   bool   vHoraValida = false;
   
   double vPreco = 0;
  
   vHoraValida = ((pHoraIni==0 && pHoraFim==0) ||
                  (Hour()>=pHoraIni && Hour()<=pHoraFim));

   for(int i=OrdersTotal()-1;i>=0;i--)    
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber()==pNumMagico)
         {
            vLote   = OrderLots();
            vTipo   = OrderType();  
            vPrecoAbertura = OrderOpenPrice();          
            vTicket = OrderTicket();
            
            break;
         }   
   }   

   if(vTicket>0)
   {
      if(vTipo==OP_BUY)   
      {
         vDiferenca = (Bid - vPrecoAbertura);
      }
      else if(vTipo==OP_SELL)
      {
         vDiferenca = (vPrecoAbertura - Ask);
      }
   
      if(vDiferenca>=vProjecao)
      {
         vTicket = OrderSend(
                     _Symbol, 
                     vTipo, 
                     pLote, 
                     vPreco, 
                     3, 0, 0, "", pNumMagico, 0, Blue);   
      }
      else if(vDiferenca<=-vProjecao)
      {
      
         if(vTipo==OP_BUY)
            vTipo=OP_SELL;   
         else
            vTipo=OP_BUY;               
      
         vLote = (vLote * 2);
      
         FecharOperacoes(-1, pNumMagico);
         vTicket = OrderSend(
                     _Symbol, 
                     vTipo, 
                     vLote, 
                     vPreco, 
                     3, 0, 0, "", pNumMagico, 0, Blue);         
      }   
   }
   
}
