import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import GradientBoostingRegressor
from sklearn import metrics
from sklearn.model_selection import train_test_split

# 文件路径
train_csv_path = '../data/train.csv'
test_csv_path = '../data/test.csv'
result_csv_path = '../data/result.csv'
submission_csv_path = '../data/202131771337 李进文.csv'

# 训练参数
random_state = 42  # 选取的随机数种子 惯例用42，因为“终极答案是42” 方便与其他模型比较

# 删除明显不必要的特征，尤其是标语、人名等字符串特征
unnecessary_features = [
    'description',
    'ein',
    'leader',
    'motto',
    'name',
    'subcategory',
    'category',
]

# 读取数据
train_data: pd.DataFrame = pd.read_csv(train_csv_path)
train_data: pd.DataFrame = train_data.iloc[:, :23]  # 截取前23列，去除空列

# 数据预处理
train_data = train_data.drop(columns=unnecessary_features)  # 除去明显不必要的特征

train_data = train_data.sort_values(by=['score'], ascending=[False])


# 把size 即慈善规模转化为数字1,2,3 对应 small mid big
def size_to_number(x:str):
    mapping = defaultdict(lambda: np.nan, {'small': 1, "mid": 2, "big": 3})
    return mapping[x]

print("把size转化为数字")
train_data['size'] = train_data['size'].apply(size_to_number)

# 把state即机构在美国的哪个州 转换为编号
states_to_index = dict()
def state_to_number(x:str):
    if not x or x=='':
        return np.nan
    if x not in states_to_index:
        states_to_index[x] = len(states_to_index)
    return states_to_index[x]

train_data['state'] = train_data['state'].apply(state_to_number)

# # 把category 即机构类别转化为数字编号
# category_to_id = dict()
#
# def category_to_number(categories:str):
#     categories = categories.split(u', ')
#     if len(categories) < 1 or categories[0] == '':
#         return np.nan
#     main_category = categories[0]
#     if main_category not in category_to_id:
#         category_to_id[main_category] = len(category_to_id)
#     return category_to_id[main_category]
#
# print("把category转化为数字编号")
# train_data['category'] = train_data['category'].apply(category_to_number)


train_data = train_data.apply(pd.to_numeric, errors='coerce')  # 将所有列转换为数值类型
train_data = train_data.dropna()  # 删除包含NaN的行

# 将score列单独提取出来
y_data = train_data['score'].values  # 提取score列
train_data = train_data.drop(columns=['score'])  # 从数据集中删除score列

# 提取特征，绘制散点图
features = train_data.columns
scaler = StandardScaler()
train_data_scaled = scaler.fit_transform(train_data)  # 标准化处理

# 绘制特征与score关系的散点图，查看特征是否相关
for feature, col in zip(features, train_data_scaled.T):
    plt.scatter(col, y_data, s=5)
    plt.title(feature)
    plt.xlabel(feature)
    plt.ylabel('score')
    plt.show()

# 通过看图分析，找出高相关性的特征，只使用它们
high_correlation_features = [
    'size',
    'ascore',
    'program_exp_p',
    'fscore'
]
train_data = train_data[high_correlation_features]


print("预处理后的train_data的形状:")
print(train_data.shape)

# 拆分数据集为训练集和验证集 取70%为训练集 剩下30%为测试集
X_train, X_val, y_train, y_val = train_test_split(train_data, y_data, test_size=0.3, random_state=random_state)

# 训练模型并预测验证集score
gbr = GradientBoostingRegressor(max_depth=4, n_estimators=3004, subsample=0.3, learning_rate=0.03)
gbr.fit(X_train, y_train)
array_predict_score = gbr.predict(X_val)

# 计算验证集的均方误差
RMSE = np.sqrt(metrics.mean_squared_error(y_val, array_predict_score))
print('RMSE:', RMSE)

# 模型预测
# 读取测试集数据
test_data = pd.read_csv(test_csv_path)
test_data = test_data.drop(columns=unnecessary_features)  # 去除字符特征

# 只需要高相关性的特征
test_data = test_data[high_correlation_features]


test_data['size'] = test_data['size'].apply(size_to_number)
# test_data['state'] = test_data['state'].apply(state_to_number)

test_data = test_data.apply(pd.to_numeric, errors='coerce')
# test_data = test_data.dropna()

# 预测测试集score
predict_score = gbr.predict(test_data)

# 保存预测结果为csv文件
origin_data = pd.read_csv(test_csv_path)
result = pd.concat([origin_data, pd.DataFrame(predict_score, columns=['predicted_score'])], axis=1)
result.to_csv(result_csv_path, index=False)

# 保存表头为: ein,score 的表格 用于提交结果
result = pd.concat([pd.DataFrame(origin_data, columns=['ein']), pd.DataFrame(predict_score, columns=['score'])], axis=1)
result.to_csv(submission_csv_path, index=False)