// @(#)root/eve:$Id: geom_alice_tpc.C 26876 2008-12-12 14:45:40Z matevz $
// Author: Matevz Tadel

// Shows geometry of ALICE TPC.

void geom_alice_tpc()
{
   TEveManager::Create();

   gGeoManager = gEve->GetGeometry("http://root.cern.ch/files/alice.root");

   TGeoNode* node = gGeoManager->GetTopVolume()->FindNode("TPC_M_1");
   TEveGeoTopNode* tpc = new TEveGeoTopNode(gGeoManager, node);
   gEve->AddGlobalElement(tpc);

   gEve->Redraw3D(kTRUE);
}
