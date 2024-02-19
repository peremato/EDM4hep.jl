using Revise
using EDM4hep
using EDM4hep.RootIO

cd(@__DIR__)

f = "root://eospublic.cern.ch//eos/experiment/fcc/ee/generation/DelphesEvents/winter2023/IDEA/p8_ee_ZZ_ecm240/events_000189367.root"
#f = "/Users/mato/cernbox/Data/events_000189367.root"
#f = "/Users/mato/cernbox/Data/events_078174375.root"
#f = "../Output_REC_rntuple.root"

reader = RootIO.Reader(f)
events = RootIO.get(reader, "events")

evt = events[1];

mcps = RootIO.get(reader, evt, "Particle"; register=false);