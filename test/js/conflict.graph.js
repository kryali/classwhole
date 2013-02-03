describe('Conflict Graph', function() {

  it('should build conflict graph', function() {
    var testSchedule = [
      {
        id: 1,
        meetings: [
          {
            days: 'M',
            start_time: {value: 0800},
            end_time: {value: 0900},
          }
        ]
      },
      {
        id: 2,
        meetings: [
          {
            days: 'M',
            start_time: {value: 0700},
            end_time: {value: 0850},
          }
        ]
      },
      {
        id: 3,
        meetings: [
          {
            days: 'M',
            start_time: {value: 1240},
            end_time: {value: 1350},
          }
        ]
      },
      {
        id: 4,
        meetings: [
          {
            days: 'M',
            start_time: {value: 1300},
            end_time: {value: 1450},
          }
        ]
      },
      {
        id: 5,
        meetings: [
          {
            days: 'M',
            start_time: {value: 1200},
            end_time: {value: 1550},
          }
        ]
      },
    ];

    var conflictGraph = new ConflictGraph();
    var graphedOptions = conflictGraph.apply(testSchedule);

    expect(graphedOptions[0].conflicts.length).toEqual(1);
    expect(graphedOptions[1].conflicts.length).toEqual(1);
    expect(graphedOptions[2].conflicts.length).toEqual(2);
    expect(graphedOptions[2].conflicts[0]).toEqual(4);
    expect(graphedOptions[2].conflicts[1]).toEqual(5);
    expect(graphedOptions[3].conflicts.length).toEqual(2);
    expect(graphedOptions[4].conflicts.length).toEqual(2);
  });

});
