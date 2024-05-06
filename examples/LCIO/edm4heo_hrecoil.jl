using EDM4hep
using EDM4hep.RootIO


#file = "/Users/gaede/data/rv02-02.sv02-02.mILD_l5_o1_v02.E250-SetA.I402003.Pe2e2h.eL.pR.n000.d_dstm_15089_0.edm4hep_v02-03-02.root"
#file = "/Users/gaede/data/rv02-02.sv02-02.mILD_l5_o1_v02.E250-SetA.I402003.Pe2e2h.eL.pR.n000.d_dstm_15089_0.edm4hep.root"
#file = "/Users/gaede/data/rv02-02.sv02-02.mILD_l5_o1_v02.E250-SetA.I402003.Pe2e2h.eL.pR.n000.d_dstm_15089_0_NEW.edm4hep.root"

#file = "/Users/mato/Downloads/rv02-02.sv02-02.mILD_l5_o1_v02.E250-SetA.I402003.Pe2e2h.eL.pR.n000.d_dstm_15089_0.edm4hep.root"
#file = "/Users/mato/Downloads/rv02-02.sv02-02.mILD_l5_o1_v02.E250-SetA.I402003.Pe2e2h.eL.pR.n000.d_dstm_15089_0_NEW.edm4hep.root"
file = "/Users/mato/Downloads/rv02-02.sv02-02.mILD_l5_o1_v02.E250-SetA.I402003.Pe2e2h.eL.pR.n000.d_dstm_15089_0.edm4hep_v02-03-02.root"
##file = "/Users/mato/Downloads/rv02-02.sv02-02.mILD_l5_o1_v02.E250_pandorapfo_10evt_edm4hep.root"
reader = RootIO.Reader(file)

dimuonmass = Float64[]
recoilmass = Float64[]

mass4v( a ) = sqrt( a[1]^2 - a[2]^2 - a[3]^2 - a[4]^2 )



events = RootIO.get(reader, "events");
#for evt in events
#    evt
#if 1==1
    evt = events[1];
    pfos = RootIO.get(reader, evt, "PandoraPFOs");
    
    muons = []
    for pfo in pfos
    
        if abs( pfo.type ) == 13

            # --- save the muon 4-vector (a simple julia vector w/ 4 elements)
            push!( muons, [ pfo.energy,  pfo.momentum.x, pfo.momentum.y, pfo.momentum.z ] )
            print( pfo.type )

        end
    end
#end

muons
