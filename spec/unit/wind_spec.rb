load File.expand_path( '../spec_helper.rb', File.dirname(__FILE__) )

RSpec::Matchers.define :be_wind do | direction, speed, gusts |
  match do | wind |
    if wind.nil?              && [ direction, speed, gusts ].all?( &:nil? )
      true
    elsif wind.direction.nil? != direction.nil?
      false
    elsif wind.speed.nil?     != speed.nil?
      false
    elsif wind.gusts.nil?     != gusts.nil?
      false
    elsif direction.is_a?( Symbol )         && wind.direction != direction
      false
    elsif direction.is_a?( M9t::Direction ) && (wind.direction.value - direction).abs > 0.01
      false
    elsif speed.is_a?( Symbol )             && wind.speed     != speed
       false
    elsif speed.is_a?( Metar::Speed )       && (wind.speed.value - speed).abs > 0.01
      false
    elsif ! wind.gusts.nil?                 && (wind.gusts.value - gusts).abs > 0.01
       false
    else
      true
    end
  end
end

describe Metar::Wind do

  context '.parse' do

    [
      [ 'treats 5 digits as degrees and kilometers per hour', '12345',       [ 123.0, 12.50, nil   ] ],
      [ 'understands 5 digits + KMH',                         '12345KMH',    [ 123.0, 12.50, nil   ] ],
      [ 'understands 5 digits + MPS',                         '12345MPS',    [ 123.0, 45.00, nil   ] ],
      [ 'understands 5 digits + KT',                          '12345KT',     [ 123.0, 23.15, nil   ] ],
      [ 'returns nil for directions outside 0 to 360',        '88845KT',     [ nil,   nil,   nil   ] ],
      [ 'understands 5 digits + G + 2 digits',                '12345G67',    [ 123.0, 12.50, 18.61 ] ],
      [ 'understands 5 digits + G + 2 digits + MPS',          '12345G67MPS', [ 123.0, 45.00, 67.00 ] ],
      [ 'understands 5 digits + G + 2 digits + KMH',          '12345G67KMH', [ 123.0, 12.50, 18.61 ] ],
      [ 'understands 5 digits + G + 2 digits + KT',           '12345G67KT',  [ 123.0, 23.15, 34.47 ] ],
      [ 'understands VRB + 2 digits'                          'VRB12',       [ :variable_direction,  3.33, nil ] ],
      [ 'understands VRB + 2 digits + KMH',                   'VRB12KMH',    [ :variable_direction,  3.33, nil ] ],
      [ 'understands VRB + 2 digits + MPS',                   'VRB12MPS',    [ :variable_direction, 12.00, nil ] ],
      [ 'understands VRB + 2 digits + KT',                    'VRB12KT',     [ :variable_direction,  6.17, nil ] ],
      [ 'understands /// + 2 digits',                         '///12',       [ :unknown_direction,   3.33, nil ] ],
      [ 'understands /// + 2 digits + KMH',                   '///12KMH',    [ :unknown_direction,   3.33, nil ] ],
      [ 'understands /// + 2 digits + MPS',                   '///12MPS',    [ :unknown_direction,  12.00, nil ] ],
      [ 'understands /// + 2 digits + KT',                    '///12KT',     [ :unknown_direction,   6.17, nil ] ],
      [ 'understands /////',                                  '/////',       [ :unknown_direction, :unknown, nil ] ],
      [ 'returns nil for badly formatted values',             'XYZ12KT',     [ nil, nil, nil ] ],
      [ 'returns nil for nil',                                'XYZ12KT',     [ nil, nil, nil ] ],
    ].each do | docstring, raw, expected |
      example docstring do
        Metar::Wind.parse( raw ).should be_wind( *expected )
      end
    end

  end

  context '#to_s' do

    it 'should return a String version'

  end


end
