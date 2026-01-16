'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface Activity {
  id: string;
  code: string;
  name: string;
  planned_start_date: string;
  duration_days: number;
  status: string;
  predecessor_activities: string[];
  dependency_type: string;
  lag_days: number;
}

export default function SchedulingManager({ projectId }: { projectId: string }) {
  const [activities, setActivities] = useState<Activity[]>([]);
  const [loading, setLoading] = useState(true);
  const [scheduling, setScheduling] = useState(false);

  useEffect(() => {
    fetchActivities();
  }, [projectId]);

  const fetchActivities = async () => {
    const { data } = await supabase
      .from('activities')
      .select('*')
      .eq('project_id', projectId)
      .order('planned_start_date');
    
    if (data) setActivities(data);
    setLoading(false);
  };

  const calculateEndDate = (startDate: string, duration: number) => {
    if (!startDate) return 'Not set';
    const start = new Date(startDate);
    const end = addWorkingDays(start, duration - 1);
    return end.toLocaleDateString();
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'bg-green-500';
      case 'in_progress': return 'bg-blue-500';
      case 'on_hold': return 'bg-yellow-500';
      default: return 'bg-gray-300';
    }
  };

  const addWorkingDays = (startDate: Date, days: number): Date => {
    const result = new Date(startDate);
    let addedDays = 0;
    
    while (addedDays < days) {
      result.setDate(result.getDate() + 1);
      // Skip weekends (Saturday = 6, Sunday = 0)
      if (result.getDay() !== 0 && result.getDay() !== 6) {
        addedDays++;
      }
    }
    return result;
  };

  const scheduleProject = async () => {
    setScheduling(true);
    
    // Get project start date
    const { data: project } = await supabase
      .from('projects')
      .select('start_date')
      .eq('id', projectId)
      .single();
    
    const projectStartDate = project?.start_date ? new Date(project.start_date) : new Date();
    
    // Find activities with no predecessors (starting activities)
    const startingActivities = activities.filter(a => 
      !a.predecessor_activities || a.predecessor_activities.length === 0
    );
    
    const scheduledActivities = new Map<string, { start: Date; end: Date }>();
    const processed = new Set<string>();
    
    const scheduleActivity = (activity: Activity): void => {
      if (processed.has(activity.id)) return;
      
      let activityStartDate = projectStartDate;
      
      // Calculate start date based on predecessors
      if (activity.predecessor_activities && activity.predecessor_activities.length > 0) {
        let latestPredecessorEnd = projectStartDate;
        
        activity.predecessor_activities.forEach(predId => {
          const predecessor = activities.find(a => a.id === predId);
          if (predecessor && !processed.has(predId)) {
            scheduleActivity(predecessor);
          }
          
          const predSchedule = scheduledActivities.get(predId);
          if (predSchedule) {
            let dependentStart = new Date(predSchedule.end);
            
            // Apply dependency type
            switch (activity.dependency_type) {
              case 'start_to_start':
                dependentStart = new Date(predSchedule.start);
                break;
              case 'finish_to_finish':
                dependentStart = new Date(predSchedule.end);
                dependentStart.setDate(dependentStart.getDate() - activity.duration_days + 1);
                break;
              case 'start_to_finish':
                dependentStart = new Date(predSchedule.start);
                dependentStart.setDate(dependentStart.getDate() - activity.duration_days + 1);
                break;
              default: // finish_to_start
                dependentStart.setDate(dependentStart.getDate() + 1);
                break;
            }
            
            // Apply lag days
            if (activity.lag_days) {
              dependentStart = addWorkingDays(dependentStart, activity.lag_days);
            }
            
            if (dependentStart > latestPredecessorEnd) {
              latestPredecessorEnd = dependentStart;
            }
          }
        });
        
        activityStartDate = latestPredecessorEnd;
      } else {
        // Use project start date for activities without predecessors
        activityStartDate = projectStartDate;
      }
      
      const activityEndDate = addWorkingDays(activityStartDate, activity.duration_days - 1);
      
      scheduledActivities.set(activity.id, {
        start: activityStartDate,
        end: activityEndDate
      });
      
      processed.add(activity.id);
    };
    
    // Schedule all activities
    activities.forEach(activity => scheduleActivity(activity));
    
    // Update database with calculated dates
    const updates = Array.from(scheduledActivities.entries()).map(([activityId, schedule]) => {
      return supabase
        .from('activities')
        .update({
          planned_start_date: schedule.start.toISOString().split('T')[0],
          planned_end_date: schedule.end.toISOString().split('T')[0]
        })
        .eq('id', activityId);
    });
    
    await Promise.all(updates);
    await fetchActivities();
    setScheduling(false);
  };

  if (loading) return <div className="p-6">Loading schedule...</div>;

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 border-b">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-lg font-bold">Project Schedule</h2>
              <p className="text-sm text-gray-600">Activity timeline and dependencies</p>
            </div>
            <button
              onClick={scheduleProject}
              disabled={scheduling}
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:opacity-50 flex items-center space-x-2"
            >
              {scheduling ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  <span>Scheduling...</span>
                </>
              ) : (
                <>
                  <span>📅</span>
                  <span>Schedule Project</span>
                </>
              )}
            </button>
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Activity</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Start Date</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">End Date</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Duration</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Dependencies</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {activities.map((activity) => (
                <tr key={activity.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div>
                      <div className="font-medium text-sm">{activity.name}</div>
                      <div className="text-xs text-gray-500">{activity.code}</div>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm">
                    {activity.planned_start_date ? new Date(activity.planned_start_date).toLocaleDateString() : 'Not set'}
                  </td>
                  <td className="px-4 py-3 text-sm">
                    {calculateEndDate(activity.planned_start_date, activity.duration_days)}
                  </td>
                  <td className="px-4 py-3 text-sm">{activity.duration_days} days</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center">
                      <div className={`w-3 h-3 rounded-full ${getStatusColor(activity.status)} mr-2`}></div>
                      <span className="text-sm capitalize">{activity.status.replace('_', ' ')}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm">
                    {activity.predecessor_activities && activity.predecessor_activities.length > 0 ? (
                      <div className="space-y-1">
                        {activity.predecessor_activities.map((predId: string) => {
                          const predActivity = activities.find(a => a.id === predId);
                          return predActivity ? (
                            <div key={predId} className="text-xs bg-gray-100 px-2 py-1 rounded">
                              {predActivity.code}
                            </div>
                          ) : null;
                        })}
                      </div>
                    ) : (
                      <span className="text-gray-400">None</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {activities.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">No activities found. Create activities in the WBS tab first.</p>
          </div>
        )}
      </div>
    </div>
  );
}