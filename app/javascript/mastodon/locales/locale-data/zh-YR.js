/*eslint eqeqeq: "off"*/
/*eslint no-nested-ternary: "off"*/

export default [
  {
    locale: "zh-YR",
    pluralRuleFunction: function(e, a) {
        return "other";
    },
    fields: {
      year: {
        displayName: "年",
        relative: {
          0: "今年",
          1: "明年",
          "-1": "去年"
        },
        relativeTime: {
          future: {
            one: "{0}年后",
            other: "{0}年后"
          },
          past: {
            one: "{0}年前",
            other: "{0}年前"
          }
        }
      },
      month: {
        displayName: "月",
        relative: {
          0: "本月",
          1: "次月",
          "-1": "上月"
        },
        relativeTime: {
          future: {
            one: "{0}月后",
            other: "{0}月后"
          },
          past: {
            one: "{0}月前",
            other: "{0}月前"
          }
        }
      },
      day: {
        displayName: "天",
        relative: {
          0: "今天",
          1: "明天",
          "-1": "昨天"
        },
        relativeTime: {
          future: {
            one: "{0}天后",
            other: "{0}天后"
          },
          past: {
            one: "{0}天前",
            other: "{0}天前"
          }
        }
      },
      hour: {
        displayName: "小时",
        relativeTime: {
          future: {
            one: "{0}小时后",
            other: "{0}小时后"
          },
          past: {
            one: "{0}小时前",
            other: "{0}小时前"
          }
        }
      },
      minute: {
        displayName: "分钟",
        relativeTime: {
          future: {
            one: "{0}分钟后",
            other: "{0}分钟后"
          },
          past: {
            one: "{0}分钟前",
            other: "{0}分钟前"
          }
        }
      },
      second: {
        displayName: "秒",
        relative: {
          0: "现在"
        },
        relativeTime: {
          future: {
            one: "{0}秒后",
            other: "{0}秒后"
          },
          past: {
            one: "{0}秒前",
            other: "{0}秒前"
          }
        }
      }
    }
  }
]