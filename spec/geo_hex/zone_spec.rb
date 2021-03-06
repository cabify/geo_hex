require 'spec_helper'

describe GeoHex::Zone do

  subject do
    described_class.new(5700, 5717, 7)
  end

  it              { should_not be_meridian_180 }
  its(:unit)      { should be_instance_of(GeoHex::Unit) }
  its(:level)     { should == 7 }
  its(:easting)   { should be_within(1).of(-17306) }
  its(:northing)  { should be_within(1).of(6710328) }
  its(:code)      { should == "QE0166383" }
  its(:lat)       { should be_within(0.0001).of(51.5006) }
  its(:lon)       { should be_within(0.0001).of(-0.1554) }
  its(:point)     { should be_instance_of(GeoHex::PP) }
  its(:polygon)   { should be_instance_of(GeoHex::Polygon) }
  its(:to_a)      { should == [5700, 5717, 7] }

  it 'should find neighbours' do
    subject.neighbours(1).size.should eq(6)
    subject.neighbours(2).size.should eq(18)
    subject.neighbours(3).size.should eq(36)
  end

  it "should find the 'right' neighbours" do
    neighbours = GeoHex.decode("PF3246648").neighbours
    neighbours.map(&:to_s).should =~ %w(PF3246645 PF3246672 PF3246656 PF3246644 PF3246680 PF3246647)
    neighbours.first.should be_instance_of(described_class)
  end

  it "should find the 'right' neighbours across multiple levels" do
    neighbours = GeoHex.decode("PC674435").neighbours(2)
    neighbours.map(&:to_s).should =~ %w(
      PC674431 PC674432 PC674434 PC674438 PC674443 PC674446
      PC674447 PC674470 PC674471 PC674406 PC674407 PC674430
      PC674444 PC674440 PC674408 PC674433 PC674437 PC674462
    )
  end

  describe "if on meridian 180" do
    subject { described_class.new(7, -2, 0) }

    it { should be_meridian_180 }
    its(:x) { should == -2 }
    its(:y) { should == 7 }
  end

  it "should be comparable" do
    subject.should == subject
    subject.should == subject.to_s
    subject.should eql(subject)
  end

  it "should support common set operations" do
    z1 = subject
    z2 = described_class.new(7, -1, 0)
    z3 = described_class.new(8, -1, 0)
    [z1, z2, z1.clone].uniq.size.should eq(2)
    ([z1, z2, z3] & [z2.clone, z3.clone]).should == [z2, z3]
    ([z1, z2, z3] - [z2.clone, z3.clone]).should == [z1]
  end

end
