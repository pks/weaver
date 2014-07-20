#include "hypergraph.hh"


int
main(int argc, char** argv)
{
  Hg::Hypergraph hg;
  Hg::io::read(hg, argv[1]);
  Hg::viterbi(hg);

  return 0;
}

